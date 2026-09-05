namespace :calendar_imports do
  desc "Synchronize every configured external calendar"
  task sync_all: :environment do
    CalendarImports::SyncAll.new.call
  rescue CalendarImports::SyncAll::SyncError => error
    abort "calendar import sync failed: #{error.message}"
  end
end
