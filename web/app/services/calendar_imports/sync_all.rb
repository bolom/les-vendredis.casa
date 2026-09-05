module CalendarImports
  class SyncAll
    class SyncError < StandardError; end

    def initialize(syncer: ->(calendar_import) { Sync.new(calendar_import) }, output: $stdout)
      @syncer = syncer
      @output = output
    end

    def call
      CalendarImport.ensure_defaults!
      failures = []

      CalendarImport.where(active: true).find_each do |calendar_import|
        syncer.call(calendar_import).call
        output.puts "#{calendar_import.provider}: synced"
      rescue StandardError => error
        failures << "#{calendar_import.provider}: #{error.class}"
        output.puts "#{calendar_import.provider}: failed"
      end

      raise SyncError, failures.join("; ") if failures.any?

      output.puts "all calendar imports synced"
    end

    private

    attr_reader :syncer, :output
  end
end
