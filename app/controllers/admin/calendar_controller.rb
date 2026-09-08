module Admin
  # Anaïs's main screen: one monthly grid combining every blocking origin
  # (manual closures, direct stays, imported Airbnb/Booking events). Pure
  # read-only aggregation on top of the existing business scopes.
  class CalendarController < BaseController
    ORIGIN_ORDER = { "manual_closure" => 0, "direct_stay" => 1, "airbnb" => 2, "booking" => 3 }.freeze

    def show
      @month = parsed_month
      @month_start = Date.new(@month.year, @month.month, 1)
      @month_end = @month_start.next_month
      grid_start = @month_start - ((@month_start.wday + 6) % 7) # Monday-first grid
      grid_end = @month_end + ((7 - ((@month_end.wday + 6) % 7)) % 7)
      ranges = blocking_ranges_between(grid_start, grid_end)
      @days = (grid_start...grid_end).map { |date| build_day(date, ranges) }
    end

    # JSON detail for one day: occupant(s), origin, and the cancel action for
    # manual closures. Consumed by the vanilla day-detail panel.
    def day
      date = begin
        Date.parse(params[:date].to_s)
      rescue Date::Error
        raise ActionController::BadRequest, "invalid date"
      end
      ranges = blocking_ranges_between(date, date + 1)
      render json: {
        date: date.iso8601,
        entries: ranges.map do |range|
          {
            occupant: range[:occupant],
            origin_label: human_origin(range[:origin]),
            range_label: date_range_label(range),
            cancel_url: range[:cancel_url],
            inquiry_url: range[:url]
          }
        end
      }
    end

    private

    def human_origin(origin)
      {
        "manual_closure" => "Blocage maison",
        "direct_stay" => "Séjour direct",
        "airbnb" => "Airbnb",
        "booking" => "Booking.com"
      }.fetch(origin, origin)
    end

    def date_range_label(range)
      from = range[:starts_on]
      to = range[:ends_on]
      if from == to
        l(from, format: "%-d %B")
      else
        "#{l(from, format: "%-d %B")} → #{l(to, format: "%-d %B")}"
      end
    end

    def parsed_month
      year = params[:year].to_i
      month = params[:month].to_i
      if year.between?(2000, 2100) && month.between?(1, 12)
        Date.new(year, month, 1)
      else
        Date.current.beginning_of_month
      end
    end

    def blocking_ranges_between(range_start, range_end)
      block_ranges = AvailabilityBlock.blocking
        .where("starts_on < ? AND ends_on > ?", range_end, range_start)
        .map do |block|
          range_for(
            block.starts_on, block.ends_on, block.kind, block_occupant(block), block_url(block),
            cancel_url: (cancel_admin_availability_block_path(block) if block.kind == "manual_closure")
          )
        end
      event_ranges = CalendarEvent.blocking
        .where("starts_on < ? AND ends_on > ?", range_end, range_start)
        .includes(:calendar_import)
        .map { |event| range_for(event.starts_on, event.ends_on, event.calendar_import.provider, event.summary.presence || "Réservation externe", nil) }
      block_ranges + event_ranges
    end

    def range_for(starts_on, ends_on, origin, occupant, url, cancel_url: nil)
      { starts_on: starts_on, ends_on: ends_on, origin: origin, occupant: occupant, url: url, cancel_url: cancel_url }
    end

    def block_occupant(block)
      if block.direct_stay?
        inquiry = block.booking_inquiries.order(:created_at).last
        inquiry&.guest_name || block.summary.presence || "Séjour direct"
      else
        block.summary.presence || "Blocage maison"
      end
    end

    def block_url(block)
      return nil unless block.direct_stay?

      inquiry = block.booking_inquiries.order(:created_at).last
      admin_booking_inquiry_path(inquiry) if inquiry
    end

    def build_day(date, ranges)
      segments = ranges
        .select { |range| range[:starts_on] <= date && date < range[:ends_on] }
        .sort_by { |range| ORIGIN_ORDER.fetch(range[:origin], 99) }
      { date: date, segments: segments, today: date == Date.current }
    end
  end
end
