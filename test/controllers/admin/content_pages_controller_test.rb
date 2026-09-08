require "test_helper"

module Admin
  class ContentPagesControllerTest < ActionDispatch::IntegrationTest
    test "redirects accounts without technical access" do
      sign_in_as users(:two)

      get admin_content_pages_path

      assert_redirected_to admin_root_path
      assert_equal "Section technique réservée aux comptes autorisés.", flash[:alert]
    end

    test "requires authentication" do
      get admin_content_pages_path

      assert_redirected_to new_session_path
    end

    test "admin can list, filter and search content pages" do
      sign_in_as users(:one)
      ContentPage.create!(path: "guide-admin", locale: "fr", title: "Guide admin", body_html: "<p>Contenu</p>")
      ContentPage.create!(path: "admin-guide", locale: "en", title: "Admin guide", body_html: "<p>Body</p>")

      get admin_content_pages_path
      assert_response :success
      assert_select "td", text: /Guide admin/

      get admin_content_pages_path, params: { locale: "en" }
      assert_select "td", text: /Guide admin/, count: 0
      assert_select "td", text: /Admin guide/

      get admin_content_pages_path, params: { q: "guide-admin" }
      assert_select "td", text: /Guide admin/
      assert_select "td", text: /Admin guide/, count: 0
    end

    test "admin can create a content page" do
      sign_in_as users(:one)

      assert_difference "ContentPage.count", 1 do
        post admin_content_pages_path, params: {
          content_page: { path: "nouvelle-page", locale: "fr", title: "Nouvelle page", body_html: "<p>Salut</p>", published: "1" }
        }
      end

      assert_redirected_to admin_content_page_path(ContentPage.order(:id).last.id)
      assert_equal "Page enregistrée.", flash[:notice]
    end

    test "admin sees validation errors when creating an invalid content page" do
      sign_in_as users(:one)
      ContentPage.create!(path: "pris", locale: "fr", title: "Pris", body_html: "<p>x</p>")

      assert_no_difference "ContentPage.count" do
        post admin_content_pages_path, params: {
          content_page: { path: "pris", locale: "fr", title: "Doublon", body_html: "<p>y</p>" }
        }
      end

      assert_response :unprocessable_entity
      assert_select "[role='alert']"
    end

    test "admin can update a content page" do
      sign_in_as users(:one)
      content_page = ContentPage.create!(path: "modifiable", locale: "fr", title: "Modifiable", body_html: "<p>Avant</p>")

      patch admin_content_page_path(content_page.id), params: {
        content_page: { title: "Après", published: "0" }
      }

      assert_redirected_to admin_content_page_path(content_page.id)
      assert_equal "Après", content_page.reload.title
      assert_equal false, content_page.published?
    end

    test "admin can preview a content page like the public site renders it" do
      sign_in_as users(:one)
      content_page = ContentPage.create!(path: "apercu", locale: "fr", title: "Aperçu", body_html: "<p>Corps visible</p>")

      get admin_content_page_path(content_page.id)

      assert_response :success
      assert_select ".admin-card", text: /Corps visible/
    end

    test "admin can destroy a content page after confirmation" do
      sign_in_as users(:one)
      content_page = ContentPage.create!(path: "supprimable", locale: "fr", title: "Supprimable", body_html: "<p>x</p>")

      get admin_content_pages_path
      assert_select "form[action='#{admin_content_page_path(content_page.id)}'] [data-lv-confirm]"

      assert_difference "ContentPage.count", -1 do
        delete admin_content_page_path(content_page.id)
      end

      assert_redirected_to admin_content_pages_path
      assert_equal "Page « Supprimable » supprimée.", flash[:notice]
    end
  end
end
