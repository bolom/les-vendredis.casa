require "test_helper"

class ContentPagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = ContentPage.create!(
      path: "a-frame",
      locale: "en",
      title: "A-frame — Les Vendredis",
      description: "A cabin in Martinique",
      canonical_url: "https://lesvendredis.casa/a-frame/",
      structured_data: '{"@type":"LodgingBusiness"}',
      body_html: '<section class="landing"><h1>The cabin</h1><script>alert(1)</script></section>'
    )
  end

  test "serves a content page with SEO and sanitized body" do
    get content_page_path(@page.path)

    assert_response :success
    assert_select "title", @page.title
    assert_select "meta[name=description][content=?]", @page.description
    assert_select "link[rel=canonical][href=?]", @page.canonical_url
    assert_select "head script[type='application/ld+json']", count: 1
    assert_select "main section.landing h1", "The cabin"
    assert_select "main script", count: 0
  end

  test "does not serve drafts" do
    @page.update!(published: false)

    get content_page_path(@page.path)

    assert_response :not_found
  end
end
