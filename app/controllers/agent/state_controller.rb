# frozen_string_literal: true

module Agent
  # Read-only operational state for agents. Any active token can read; no
  # secrets, no private iCal URLs, no technical diagnostics ever leave this
  # layer. Shapes are stable maps, not model dumps, so the JSON contract
  # survives internal refactors.
  class StateController < BaseController
    def house
      render json: {
        house: "Les Vendredis",
        today: Date.current.iso8601,
        next_arrivals: HouseState.upcoming_arrivals.map { |stay| stay_json(stay) },
        next_departures: HouseState.upcoming_departures.map { |stay| stay_json(stay) },
        pending_booking_requests: HouseState.pending_inquiries.map { |inquiry| inquiry_json(inquiry) },
        calendar_imports: HouseState.calendar_imports.map { |import| import_json(import) },
        action_needed: HouseState.anomalies
      }
    end

    def calendar
      from = parse_date_param(:from) || Date.current.beginning_of_month
      to = parse_date_param(:to) || from.next_month
      raise Agent::Errors::UnprocessableError, "to must be after from" unless to > from
      raise Agent::Errors::UnprocessableError, "range cannot exceed 93 days" if (to - from).to_i > 93

      render json: {
        from: from.iso8601,
        to: to.iso8601,
        entries: HouseState.calendar(from: from, to: to).map { |entry| calendar_entry_json(entry) }
      }
    end

    def booking_requests
      inquiries = BookingInquiry.order(created_at: :desc)
      inquiries = inquiries.where(status: params[:status]) if params[:status].in?(BookingInquiry.statuses.keys)

      render json: {
        booking_requests: inquiries.limit(100).map { |inquiry| inquiry_json(inquiry) }
      }
    end

    def booking_request
      inquiry = BookingInquiry.find(params[:id])
      render json: inquiry_json(inquiry).merge(
        price_eur: inquiry_price(inquiry)&.to_s("F"),
        block_id: inquiry.availability_block_id
      )
    end

    private

    def stay_json(stay)
      {
        starts_on: stay.starts_on.iso8601,
        ends_on: stay.ends_on.iso8601,
        occupant: stay.occupant
      }
    end

    def inquiry_json(inquiry)
      {
        id: inquiry.id,
        reference: inquiry.public_reference,
        guest_name: inquiry.guest_name,
        status: inquiry.status,
        check_in: inquiry.check_in.iso8601,
        check_out: inquiry.check_out.iso8601,
        nights: inquiry.nights,
        adults: inquiry.adults,
        children: inquiry.children,
        created_at: inquiry.created_at.iso8601
      }
    end

    def import_json(import)
      {
        provider: import.provider,
        last_status: import.last_status,
        last_synced_at: import.last_synced_at&.iso8601,
        stale: import.stale?
      }
    end

    def calendar_entry_json(entry)
      {
        source: entry[:source],
        starts_on: entry[:starts_on].iso8601,
        ends_on: entry[:ends_on].iso8601,
        occupant: entry[:occupant],
        inquiry_reference: entry[:inquiry_reference],
        cancelable: entry[:cancelable]
      }
    end

    # Same human-language price as the admin inquiry screen: configured
    # nightly price times requested nights, nil when unconfigured.
    def inquiry_price(inquiry)
      price = StayRule.current.nightly_price_eur
      price&.*(inquiry.nights)
    end

    def parse_date_param(name)
      return nil if params[name].blank?

      Date.iso8601(params[name])
    rescue ArgumentError, TypeError
      raise Agent::Errors::UnprocessableError, "#{name} must be an ISO date"
    end
  end
end
