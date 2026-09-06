require "test_helper"

class ContentPages::ImporterTest < ActiveSupport::TestCase
  test "imports every preserved page idempotently" do
    importer = ContentPages::Importer.new

    assert_equal 21, importer.call
    assert_equal 21, ContentPage.count
    assert_equal 21, importer.call
    assert_equal 21, ContentPage.count
    assert_equal 14, ContentPage.where(locale: "fr").count
    assert_equal 7, ContentPage.where(locale: "en").count
  end

  test "preserves SEO metadata and structured data" do
    ContentPages::Importer.new.call
    page = ContentPage.find_by!(path: "unique-stay-martinique")

    assert_equal "en", page.locale
    assert page.title.present?
    assert page.description.present?
    assert_equal "https://lesvendredis.casa/unique-stay-martinique/", page.canonical_url
    assert_includes page.structured_data, "LodgingBusiness"
  end
end
