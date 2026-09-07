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
    assert_kind_of Array, JSON.parse(page.structured_data)
    assert_includes page.structured_data, "LodgingBusiness"
  end

  test "removes layout chrome ids from imported bodies but keeps page-owned content" do
    ContentPages::Importer.new.call
    gallery_page = ContentPage.find_by!(path: "unique-stay-martinique")
    booking_page = ContentPage.find_by!(path: "come-stay")

    assert_no_match(/id="lightbox"/, gallery_page.body_html)
    assert_no_match(/id="top-bar"/, gallery_page.body_html)
    assert_no_match(/id="mobile-nav"/, gallery_page.body_html)
    assert_no_match(/onclick=/, gallery_page.body_html)
    assert_includes gallery_page.body_html, 'data-lv-action="open-lightbox"'
    assert_includes booking_page.body_html, "data-email-link"
    assert_includes booking_page.body_html, "data-ep-u"
    assert_includes booking_page.body_html, 'id="availability-cal"'
  end
end
