require "test_helper"

class Journal::ImporterTest < ActiveSupport::TestCase
  test "imports every Rails-owned journal source idempotently" do
    importer = Journal::Importer.new

    assert_equal 35, importer.call
    assert_equal 35, JournalPost.count
    assert_equal 35, importer.call
    assert_equal 35, JournalPost.count
    assert_equal 19, JournalPost.where(locale: "en").count
    assert_equal 16, JournalPost.where(locale: "fr").count
  end
end
