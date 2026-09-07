require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home is public" do
    create_post(locale: "en")

    get root_path

    assert_response :success
    assert_select "html[lang=en]"
    assert_select "h1", /Les Vendredis is the real life/
    assert_select ".home-journal-featured"
    assert_select ".newsletter-form"
    assert_select ".gallery-section"
    assert_select "#lightbox"
    assert_select "a[href='#{new_booking_inquiry_path}']"
  end

  test "french home is public" do
    create_post(locale: "fr")

    get french_home_path

    assert_response :success
    assert_select "html[lang=fr]"
    assert_select "h1", /Les Vendredis, c’est la vraie vie/
    assert_select ".faq-section"
  end

  test "health check is public" do
    get rails_health_check_path

    assert_response :success
  end

  private

  def create_post(locale:)
    JournalPost.create!(
      title: locale == "fr" ? "Une nouvelle histoire" : "A new story",
      slug: locale == "fr" ? "une-nouvelle-histoire" : "a-new-story",
      locale: locale,
      summary: "Summary",
      body_markdown: "# Hello",
      published_on: Date.current,
      published: true
    )
  end
end
