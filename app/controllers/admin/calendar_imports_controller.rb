module Admin
  # Only the manual sync trigger lives here; the readable per-platform state is
  # CalendarsController and the raw details are DiagnosticsController. The
  # enqueue logic is shared with the agent API (CalendarImports service).
  class CalendarImportsController < BaseController
    def sync
      calendar_import = CalendarImport.find(params[:id])
      CalendarImports.enqueue_sync(calendar_import.provider)
      redirect_to admin_calendars_path, notice: "Synchronisation de #{t("admin.calendar_imports.platforms.#{calendar_import.provider}", default: calendar_import.provider)} relancée. Elle s’exécute en tâche de fond."
    end
  end
end
