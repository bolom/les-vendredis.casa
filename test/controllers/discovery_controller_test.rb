require "test_helper"

class DiscoveryControllerTest < ActionDispatch::IntegrationTest
  test "sitemaps include published content and exclude drafts and noindex pages" do
    ContentPage.create!(path: "cabin", locale: "en", title: "Cabin", body_html: "Cabin")
    ContentPage.create!(path: "hidden", locale: "en", title: "Hidden", body_html: "Hidden", robots: "noindex")
    ContentPage.create!(path: "draft", locale: "en", title: "Draft", body_html: "Draft", published: false)
    get "/sitemap.xml"
    assert_response :success
    locations = Nokogiri::XML(response.body).remove_namespaces!.css("loc").map(&:text)
    assert_includes locations, "https://lesvendredis.casa/cabin/"
    refute_includes locations, "https://lesvendredis.casa/hidden/"
    refute_includes locations, "https://lesvendredis.casa/draft/"
    get "/fr/sitemap.xml"
    assert_response :success
    assert_includes response.body, "https://lesvendredis.casa/fr/"
    refute_includes response.body, "https://lesvendredis.casa/cabin/"
  end

  test "discovery documents are valid XML" do
    %w[/sitemap_index.xml /feed.xml].each do |path|
      get path
      assert_response :success
      assert_empty Nokogiri::XML(response.body).errors
    end
  end

  test "machine discovery documents point to Rails booking API" do
    get "/llms.txt"
    assert_response :success
    assert_includes response.body, "POST /book"
    assert_includes response.body, "https://lesvendredis.casa"
    refute_includes response.body, "tail1aced7"

    get "/.well-known/agent.json"
    assert_response :success
    body = response.parsed_body
    assert_equal "https://lesvendredis.casa/book", body.dig("api", "book")
    assert_equal "EURC", body.dig("x402", "asset")
  end
end
