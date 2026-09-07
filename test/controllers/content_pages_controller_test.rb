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

  test "keeps gallery handlers and protected email markup the layout does not own" do
    @page.update!(
      body_html: <<~HTML
        <section class="gallery"><div class="gallery-item" data-lv-action="open-lightbox" data-lv-index="0"><img src="/images/jpk-cabane-vegetation-palmiers.webp" alt="gallery"></div></section>
        <a href="#" data-email-link data-ep-u="olleh" data-ep-d="zshdjfpm">Email</a>
        <span data-email-text data-ep-u="olleh" data-ep-d="zshdjfpm">hidden</span>
      HTML
    )

    get content_page_path(@page.path)

    assert_select "main [data-lv-action='open-lightbox'][data-lv-index='0']"
    assert_select "main a[data-email-link][data-ep-u='olleh']"
    assert_select "main [data-email-text][data-ep-d='zshdjfpm']"
  end

  test "imported pages do not duplicate layout element ids" do
    ContentPages::Importer.new.call
    get content_page_path("unique-stay-martinique")

    assert_response :success
    assert_select "#top-bar", count: 1
    assert_select "#lightbox", count: 1
    assert_select "#mobile-nav", count: 1
  end
end
