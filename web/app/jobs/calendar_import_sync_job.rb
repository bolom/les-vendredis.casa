class CalendarImportSyncJob < ApplicationJob
  queue_as :default

  def perform(provider = nil)
    if provider.present?
      CalendarImports::Sync.new(CalendarImport.find_or_create_by!(provider: provider)).call
    else
      CalendarImport.ensure_defaults!
      CalendarImport.where(active: true).find_each { |calendar_import| CalendarImports::Sync.new(calendar_import).call }
    end
  end
end
