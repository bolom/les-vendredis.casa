module Admin
  # Technical zone: raw synchronization details per import provider
  # (timestamps, durations, event counts, errors) for Bolo only.
  class DiagnosticsController < BaseController
    before_action :require_technical_access

    before_action :ensure_calendar_imports

    def index
      @calendar_imports = CalendarImport.order(:provider)
      @event_counts = CalendarEvent.group(:calendar_import_id).count
    end

    private

    def ensure_calendar_imports
      CalendarImport.ensure_defaults!
    end
  end
end
