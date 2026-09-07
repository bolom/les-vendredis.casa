require "test_helper"

class JournalPostTest < ActiveSupport::TestCase
  test "requires a URL-safe slug unique within its locale" do
    attributes = {
      title: "A story",
      slug: "a-story",
      locale: "en",
      body_markdown: "Body",
      published_on: Date.current
    }
    JournalPost.create!(attributes)

    duplicate = JournalPost.new(attributes)
    french_translation = JournalPost.new(attributes.merge(locale: "fr"))

    assert_not duplicate.valid?
    assert french_translation.valid?
  end

  test "published scope excludes drafts and future posts" do
    create_post(slug: "visible")
    create_post(slug: "draft", published: false)
    create_post(slug: "future", published_on: Date.tomorrow)

    assert_equal [ "visible" ], JournalPost.published.pluck(:slug)
  end

  private

  def create_post(slug:, published: true, published_on: Date.current)
    JournalPost.create!(
      title: slug.titleize,
      slug: slug,
      locale: "en",
      body_markdown: "Body",
      published: published,
      published_on: published_on
    )
  end
end
