require "test_helper"
require "stringio"

class CalendarImports::SyncAllTest < ActiveSupport::TestCase
  test "creates and synchronizes every supported calendar" do
    synced = []
    syncer = ->(calendar_import) { -> { synced << calendar_import.provider } }

    CalendarImports::SyncAll.new(syncer: syncer, output: StringIO.new).call

    assert_equal CalendarImport::PROVIDERS.sort, synced.sort
  end

  test "skips inactive calendars" do
    CalendarImport.create!(provider: "airbnb", active: false)
    synced = []
    syncer = ->(calendar_import) { -> { synced << calendar_import.provider } }

    CalendarImports::SyncAll.new(syncer: syncer, output: StringIO.new).call

    assert_equal [ "booking" ], synced
  end

  test "attempts remaining calendars and reports all failures" do
    attempted = []
    secret_url = "https://calendar.example.test/private-token.ics"
    output = StringIO.new
    syncer = lambda do |calendar_import|
      lambda do
        attempted << calendar_import.provider
        raise "request failed for #{secret_url}" if calendar_import.provider == "airbnb"
      end
    end

    error = assert_raises(CalendarImports::SyncAll::SyncError) do
      CalendarImports::SyncAll.new(syncer: syncer, output: output).call
    end

    assert_equal CalendarImport::PROVIDERS.sort, attempted.sort
    assert_match "airbnb: RuntimeError", error.message
    assert_not_includes error.message, secret_url
    assert_not_includes output.string, secret_url
  end
end
