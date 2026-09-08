require "test_helper"
require "stringio"

class CalendarImports::SyncAllJobTest < ActiveSupport::TestCase
  test "attempts every active provider, syncs booking, and fails globally when airbnb fails" do
    attempted = []
    syncer = lambda do |calendar_import|
      lambda do
        attempted << calendar_import.provider
        raise "airbnb ical fetch failed" if calendar_import.provider == "airbnb"
      end
    end

    error = assert_raises(CalendarImports::SyncAll::SyncError) do
      run_job(syncer: syncer)
    end

    assert_equal CalendarImport::PROVIDERS.sort, attempted.sort
    assert_includes attempted, "booking"
    assert_match "airbnb: RuntimeError", error.message
  end

  test "succeeds when every active provider syncs" do
    synced = []
    syncer = ->(calendar_import) { -> { synced << calendar_import.provider } }

    run_job(syncer: syncer)

    assert_equal CalendarImport::PROVIDERS.sort, synced.sort
  end

  test "never attempts inactive providers" do
    CalendarImport.create!(provider: "airbnb", active: false)
    synced = []
    syncer = ->(calendar_import) { -> { synced << calendar_import.provider } }

    run_job(syncer: syncer)

    assert_equal [ "booking" ], synced
  end

  test "recurring production schedule targets the resilient job" do
    config = YAML.load_file(Rails.root.join("config/recurring.yml"))
    entry = config.dig("production", "sync_calendar_imports")

    assert_equal "CalendarImports::SyncAllJob", entry["class"]
  end

  private

  def run_job(syncer:, output: StringIO.new)
    job = CalendarImports::SyncAllJob.new
    job.define_singleton_method(:syncer) { syncer }
    job.define_singleton_method(:output) { output }
    job.perform
  end
end
