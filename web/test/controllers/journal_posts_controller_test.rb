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
    assert_select "script", count: 0
  end

  test "keeps French and English slugs isolated" do
    get french_journal_post_path(@post.slug)

    assert_response :not_found
  end
end
