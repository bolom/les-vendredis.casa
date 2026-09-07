require "test_helper"

class JournalPostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = JournalPost.create!(
      title: "The garden",
      slug: "the-garden",
      locale: "en",
      summary: "A garden story",
      body_markdown: "## Growing\n\n<script>alert('no')</script> **Mangoes**",
      published_on: Date.current
    )
  end

  test "serves the English journal and article" do
    get journal_path
    assert_response :success
    assert_select "a[href='#{journal_post_path(@post)}'] .home-journal-secondary-title", "The garden"

    get journal_post_path(@post)
    assert_response :success
    assert_select "h1", "The garden"
    assert_select ".article-body h2", "Growing"
    assert_select ".article-body strong", "Mangoes"
    assert_select ".article-body script", count: 0
  end

  test "keeps French and English slugs isolated" do
    get french_journal_post_path(@post.slug)

    assert_response :not_found
  end

  test "formats French journal dates in French" do
    post_fr = JournalPost.create!(
      title: "Le jardin",
      slug: "le-jardin",
      locale: "fr",
      summary: "Une histoire de jardin",
      body_markdown: "**Mangues**",
      published_on: Date.new(2026, 1, 17)
    )

    get french_journal_path
    assert_response :success
    assert_select "time", /17 janvier 2026/
    assert_no_match(/17 January 2026/, response.body)
  end
end
