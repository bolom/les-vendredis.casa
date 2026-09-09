module Admin
  # Anaïs's home screen: upcoming arrivals/departures, inquiries to handle,
  # external calendar health — no technical counters. All business logic
  # lives in HouseState (shared with the agent API); this controller only
  # renders it.
  class DashboardController < BaseController
    def show
      @upcoming_arrivals = HouseState.upcoming_arrivals
      @upcoming_departures = HouseState.upcoming_departures
      @inquiries_to_handle = HouseState.pending_inquiries(limit: 8)
      @calendar_imports = HouseState.calendar_imports
      @date_conflicts = HouseState.date_conflicts
    end
  end
end
