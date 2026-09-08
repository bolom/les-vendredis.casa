module Admin
  # Anaïs's home screen: upcoming arrivals/departures, inquiries to handle,
  # external calendar health — no technical counters.
  class DashboardController < BaseController
    def show
      @upcoming_arrivals = AvailabilityBlock.blocking.where(starts_on: Date.current..14.days.from_now).order(:starts_on).limit(6)
      @upcoming_departures = AvailabilityBlock.blocking.where(ends_on: Date.current..14.days.from_now).order(:ends_on).limit(6)
      @inquiries_to_handle = BookingInquiry.where(status: %w[new contacted]).order(created_at: :asc).limit(8)
      @calendar_imports = CalendarImport.order(:provider)
      @date_conflicts = build_date_conflicts
    end

    private

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
