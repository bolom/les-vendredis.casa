module Admin
  class CalendarImportsController < BaseController
    before_action :ensure_calendar_imports

    def index
      @calendar_imports = CalendarImport.order(:provider)
    end

    def sync
      calendar_import = CalendarImport.find(params[:id])
      CalendarImportSyncJob.perform_later(calendar_import.provider)
      redirect_to admin_calendar_imports_path, notice: "Synchronisation du calendrier #{calendar_import.provider} lancée. Elle s’exécute en tâche de fond."
    end

    private

    def ensure_calendar_imports
      CalendarImport.ensure_defaults!
    end
  end
end
