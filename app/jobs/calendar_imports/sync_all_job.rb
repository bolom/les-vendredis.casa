module CalendarImports
  class SyncAllJob < ApplicationJob
    queue_as :default

    def perform
      CalendarImports::SyncAll.new(syncer: syncer, output: output).call
    end

    private

    def syncer
      ->(calendar_import) { Sync.new(calendar_import) }
    end

    def output
      $stdout
    end
  end
end
