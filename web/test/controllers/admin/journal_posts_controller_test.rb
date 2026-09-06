require "test_helper"

module Admin
  class JournalPostsControllerTest < ActionDispatch::IntegrationTest
    test "redirects unauthenticated visitors" do
      get admin_journal_posts_path

      assert_redirected_to new_session_path
    end

    test "admin can create and edit journal posts" do
      sign_in_as users(:one)

      assert_difference "JournalPost.count", 1 do
        post admin_journal_posts_path, params: {
          journal_post: {
            title: "New beach note",
            slug: "new-beach-note",
            locale: "fr",
            summary: "Short summary",
            body_markdown: "# Hello",
            tag: "news",
            image_path: "/images/test.webp",
            image_alt: "Test image",
            published_on: Date.current.to_s,
            published: "1"
          }
        }
      end

      post = JournalPost.order(:id).last
      assert_redirected_to edit_admin_journal_post_path(post.id)
      assert_equal "New beach note", post.title
      assert_equal true, post.published?

      patch admin_journal_post_path(post.id), params: {
        journal_post: {
          title: "Updated note",
          slug: "new-beach-note",
          locale: "fr",
          summary: "Updated summary",
          body_markdown: "# Updated",
          tag: "guide",
          image_path: "/images/updated.webp",
          image_alt: "Updated image",
          published_on: Date.current.to_s,
          published: "0"
        }
      }

      assert_redirected_to edit_admin_journal_post_path(post.id)
      assert_equal "Updated note", post.reload.title
      assert_equal false, post.published?
    end

    test "admin sees validation errors" do
      sign_in_as users(:one)
      post = JournalPost.create!(
        title: "Draft note",
        slug: "draft-note",
        locale: "en",
        body_markdown: "Body",
        published_on: Date.current,
        published: false
      )

      patch admin_journal_post_path(post.id), params: {
        journal_post: {
          title: "",
          slug: "draft-note",
          locale: "en",
          body_markdown: "Body",
          published_on: Date.current.to_s,
          published: "0"
        }
      }

      assert_response :unprocessable_entity
      assert_select "[role='alert']", /Title can't be blank/
    end
  end
end
