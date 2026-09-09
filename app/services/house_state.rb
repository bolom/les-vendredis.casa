# frozen_string_literal: true

module HouseState
  # Consolidated read model for the house: what the human admin dashboard
  # shows (upcoming arrivals/departures, inquiries to handle, calendar
  # health, conflicts) expressed as plain data so both the admin HTML
  # screens and the agent API consume the same business truth.
  #
  # This module is the extraction target of the logic previously inlined in
  # Admin::DashboardController; the controller now renders these records.
  UPCOMING_HORIZON = 14.days
  PENDING_INQUIRY_STATUSES = %w[new contacted].freeze
  MAX_CONFLICTS = 5

  module_function

  UpcomingStay = Data.define(:starts_on, :ends_on, :occupant)

  # The house only cares about real stays: direct bookings plus imported
  # Airbnb/Booking reservations. A manual closure (painting, maintenance)
  # is not an arrival or a departure, so it never shows up here.
  def upcoming_stays(starts_on:, horizon: UPCOMING_HORIZON)
    limit_date = horizon.from_now.to_date
    date_column = starts_on ? :starts_on : :ends_on

    stay_blocks = AvailabilityBlock.blocking
      .where(kind: "direct_stay", date_column => Date.current..limit_date)
      .includes(:booking_inquiries)
    imported_events = CalendarEvent.blocking
      .where(date_column => Date.current..limit_date)
      .includes(:calendar_import)

    (stay_blocks.map { |block| UpcomingStay.new(block.starts_on, block.ends_on, block_occupant(block)) } +
      imported_events.map { |event| UpcomingStay.new(event.starts_on, event.ends_on, external_occupant(event)) })
      .sort_by { |stay| stay.public_send(date_column) }
  end

  def upcoming_arrivals(limit: 6)
    upcoming_stays(starts_on: true).first(limit)
  end

  def upcoming_departures(limit: 6)
    upcoming_stays(starts_on: false).first(limit)
  end

  def pending_inquiries(limit: nil)
    scope = BookingInquiry.where(status: PENDING_INQUIRY_STATUSES).order(created_at: :asc)
    scope = scope.limit(limit) if limit
    scope
  end

  # One consolidated month (or arbitrary range) of every blocking origin:
  # manual closures, direct stays, imported Airbnb/Booking events.
  def calendar(from:, to:)
    blocks = AvailabilityBlock.blocking
      .where("starts_on < ? AND ends_on > ?", to, from)
      .order(:starts_on)
    events = CalendarEvent.blocking
      .where("starts_on < ? AND ends_on > ?", to, from)
      .includes(:calendar_import)
      .order(:starts_on)

    blocks.map { |block| calendar_entry_block(block) } +
      events.map { |event| calendar_entry_event(event) }
  end

  def calendar_imports
    CalendarImport.order(:provider)
  end

  # Useful conflicts only: a blocking range (house closure or direct stay)
  # overlapping an imported Airbnb/Booking event means the platforms are
  # advertising dates we consider taken — worth a human look.
  def date_conflicts(limit: MAX_CONFLICTS)
    blocks = AvailabilityBlock.blocking.where("ends_on > ?", Date.current).order(:starts_on)
    events = CalendarEvent.blocking.where("ends_on > ?", Date.current).includes(:calendar_import).order(:starts_on)
    conflicts = []
    blocks.each do |block|
      events.each do |event|
        next unless event.starts_on < block.ends_on && block.starts_on < event.ends_on

        conflicts << { block: block, event: event }
        break if conflicts.size >= limit
      end
      break if conflicts.size >= limit
    end
    conflicts
  end

  # Anomalies actually worth acting on, each with the agent capability that
  # could address it. Deliberately conservative: only states a machine can
  # genuinely act on or that a human must review.
  def anomalies
    list = []
    calendar_imports.each do |import|
      if import.last_status == "failed"
        list << {
          kind: "calendar_sync_failed",
          target: "calendar_import:#{import.provider}",
          message: "Last #{import.provider} sync failed.",
          action: "sync_calendars"
        }
      elsif import.stale?
        list << {
          kind: "calendar_sync_stale",
          target: "calendar_import:#{import.provider}",
          message: "#{import.provider} has not synced in the last 30 minutes.",
          action: "sync_calendars"
        }
      end
    end
    date_conflicts.each do |conflict|
      list << {
        kind: "calendar_conflict",
        target: "availability_block:#{conflict[:block].id}",
        message: "House range overlaps an imported #{conflict[:event].calendar_import.provider} event.",
        action: "review"
      }
    end
    list
  end

  def block_occupant(block)
    if block.direct_stay?
      block.booking_inquiries.order(:created_at).last&.guest_name || block.summary.presence || "Séjour direct"
    else
      block.summary.presence || "Blocage maison"
    end
  end

  def external_occupant(event)
    event.summary.presence || "Réservation externe · #{event.calendar_import.provider}"
  end

  def calendar_entry_block(block)
    {
      source: block.kind,
      starts_on: block.starts_on,
      ends_on: block.ends_on,
      occupant: block_occupant(block),
      inquiry_reference: block.booking_inquiries.order(:created_at).last&.public_reference,
      cancelable: block.kind == "manual_closure"
    }
  end

  def calendar_entry_event(event)
    {
      source: event.calendar_import.provider,
      starts_on: event.starts_on,
      ends_on: event.ends_on,
      occupant: event.summary.presence || "Réservation externe",
      inquiry_reference: nil,
      cancelable: false
    }
  end
end
