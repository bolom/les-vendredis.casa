module Admin
  # Day-to-day external calendar state for Anaïs: one simple line per platform.
  # Raw sync diagnostics live in the technical zone (DiagnosticsController).
  class CalendarsController < BaseController
    before_action :ensure_calendar_imports

    def index
      @calendar_imports = CalendarImport.order(:provider)
    end

    private

    def ensure_calendar_imports
      CalendarImport.ensure_defaults!
    end
  end
end
