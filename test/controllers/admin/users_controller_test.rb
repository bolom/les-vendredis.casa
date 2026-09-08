require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "redirects accounts without technical access" do
      sign_in_as users(:two)

      get admin_users_path

      assert_redirected_to admin_root_path
      assert_equal "Section technique réservée aux comptes autorisés.", flash[:alert]
    end

    test "requires authentication" do
      get admin_users_path

      assert_redirected_to new_session_path
    end

    test "admin can list users" do
      sign_in_as users(:one)

      get admin_users_path

      assert_response :success
      assert_select "td", text: /one@example.com/
    end

    test "admin can create a user" do
      sign_in_as users(:one)

      assert_difference "User.count", 1 do
        post admin_users_path, params: {
          user: { email_address: "nouveau@example.com", password: "motdepasse1", password_confirmation: "motdepasse1" }
        }
      end

      assert_redirected_to admin_users_path
      assert_equal "Utilisateur « nouveau@example.com » créé.", flash[:notice]
    end

    test "admin sees validation errors when creating a duplicate user" do
      sign_in_as users(:one)

      assert_no_difference "User.count" do
        post admin_users_path, params: {
          user: { email_address: "one@example.com", password: "motdepasse1", password_confirmation: "motdepasse1" }
        }
      end

      assert_response :unprocessable_entity
      assert_select "[role='alert']"
    end

    test "admin can update a user email without changing the password" do
      sign_in_as users(:one)

      patch admin_user_path(users(:two)), params: {
        user: { email_address: "deux@example.com", password: "", password_confirmation: "" }
      }

      assert_redirected_to admin_users_path
      assert_equal "deux@example.com", users(:two).reload.email_address
      assert User.authenticate_by(email_address: "deux@example.com", password: "password")
    end

    test "admin cannot delete their own account" do
      sign_in_as users(:one)

      assert_no_difference "User.count" do
        delete admin_user_path(users(:one))
      end

      assert_redirected_to admin_users_path
      assert_equal "Vous ne pouvez pas supprimer votre propre compte.", flash[:alert]
    end

    test "admin cannot change their own technical access" do
      sign_in_as users(:one)

      patch admin_user_path(users(:one)), params: {
        user: { email_address: "one@example.com", technical_access: "0" }
      }

      assert_redirected_to edit_admin_user_path(users(:one))
      assert_equal "Vous ne pouvez pas modifier votre propre accès à la zone technique.", flash[:alert]
      assert users(:one).reload.technical_access?
    end

    test "admin can toggle technical access of another user" do
      sign_in_as users(:one)

      patch admin_user_path(users(:two)), params: {
        user: { email_address: "two@example.com", technical_access: "1" }
      }

      assert_redirected_to admin_users_path
      assert users(:two).reload.technical_access?
    end

    test "admin can delete another user" do
      sign_in_as users(:one)

      get admin_users_path
      assert_select "form[action='#{admin_user_path(users(:two))}'] [data-lv-confirm]"

      assert_difference "User.count", -1 do
        delete admin_user_path(users(:two))
      end

      assert_redirected_to admin_users_path
    end
  end
end
