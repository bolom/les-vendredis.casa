# frozen_string_literal: true

# Shared iCal sync trigger for the human admin and the agent API. Both just
# enqueue the existing job; the actual fetching, parsing and state writing
# stay in CalendarImports::Sync. Returns the reloaded import (its readable
# state stays stale until the background job runs).
#
# Lives in the parent namespace file on purpose: app/jobs/calendar_imports/
# also opens this module, and a nested enqueue_sync.rb would never be loaded
# by Zeitwerk once the parent constant exists.
module CalendarImports
  module_function

  def enqueue_sync(provider)
    calendar_import = CalendarImport.find_by!(provider: provider)
    CalendarImportSyncJob.perform_later(calendar_import.provider)
    calendar_import.reload
  end
end
