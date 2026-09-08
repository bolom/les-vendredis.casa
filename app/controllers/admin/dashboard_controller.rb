module Admin
  # Anaïs's home screen: upcoming arrivals/departures, inquiries to handle,
  # external calendar health — no technical counters.
  class DashboardController < BaseController
    UpcomingStay = Data.define(:starts_on, :ends_on, :occupant)

    def show
      @upcoming_arrivals = upcoming_stays(starts_on: true).first(6)
      @upcoming_departures = upcoming_stays(starts_on: false).first(6)
      @inquiries_to_handle = BookingInquiry.where(status: %w[new contacted]).order(created_at: :asc).limit(8)
      @calendar_imports = CalendarImport.order(:provider)
      @date_conflicts = build_date_conflicts
    end

    private

    # The house only cares about real stays: direct bookings plus imported
    # Airbnb/Booking reservations. A manual closure (painting, maintenance)
    # is not an arrival or a departure, so it never shows up here.
    # starts_on: true sorts by arrival date, false by departure date.
    def upcoming_stays(starts_on:)
      horizon = 14.days.from_now.to_date
      date_column = starts_on ? :starts_on : :ends_on

      stay_blocks = AvailabilityBlock.blocking
        .where(kind: "direct_stay", date_column => Date.current..horizon)
        .includes(:booking_inquiries)
      imported_events = CalendarEvent.blocking
        .where(date_column => Date.current..horizon)
        .includes(:calendar_import)

      (stay_blocks.map { |block| UpcomingStay.new(block.starts_on, block.ends_on, block_occupant(block)) } +
        imported_events.map { |event| UpcomingStay.new(event.starts_on, event.ends_on, external_occupant(event)) })
        .sort_by { |stay| stay.public_send(date_column) }
    end

    def block_occupant(block)
      if block.direct_stay?
        block.booking_inquiries.order(:created_at).last&.guest_name || block.summary.presence || "Séjour direct"
      else
        block.summary.presence || "Blocage maison"
      end
    end

    def external_occupant(event)
      event.summary.presence || "Réservation externe · #{human_platform(event.calendar_import.provider)}"
    end

    # Useful conflicts only: a blocking range (house closure or direct stay)
    # overlapping an imported Airbnb/Booking event means the platforms are
    # advertising dates we consider taken — worth a human look.
    def build_date_conflicts
      blocks = AvailabilityBlock.blocking.where("ends_on > ?", Date.current).order(:starts_on)
      events = CalendarEvent.blocking.where("ends_on > ?", Date.current).includes(:calendar_import).order(:starts_on)
      conflicts = []
      blocks.each do |block|
        events.each do |event|
          next unless event.starts_on < block.ends_on && block.starts_on < event.ends_on

          conflicts << { block: block, event: event }
          break if conflicts.size >= 5
        end
        break if conflicts.size >= 5
      end
      conflicts
    end
  end
end
