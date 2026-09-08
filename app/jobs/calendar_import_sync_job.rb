class CalendarImportSyncJob < ApplicationJob
  queue_as :default

  # Targeted sync (one provider, admin actions). The recurring scheduler uses
  # CalendarImports::SyncAllJob instead, which attempts every active provider
  # even when one of them fails.
  def perform(provider = nil)
    return CalendarImports::SyncAllJob.perform_now if provider.blank?

    CalendarImports::Sync.new(CalendarImport.find_or_create_by!(provider: provider)).call
  end
end
