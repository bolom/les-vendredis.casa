require "test_helper"

class AdminDashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated visitor to the sign in page" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "allows an authenticated administrator" do
    sign_in_as users(:one)

    get admin_root_path

    assert_response :success
    assert_select "h1", "Tableau de bord"
  end

  test "shows useful counters" do
    sign_in_as users(:one)
    create_inquiry(status: "new")
    create_inquiry(status: "declined")
    JournalPost.create!(title: "Brouillon", slug: "brouillon", locale: "fr", body_markdown: "x", published_on: Date.current, published: false)

    get admin_root_path

    assert_select ".admin-counter strong", text: "1"
    assert_select ".admin-counter", text: /articles du journal en brouillon/
  end

  test "links every back-office section from the navigation" do
    sign_in_as users(:one)

    get admin_root_path

    %w[
      admin_root_path
      admin_booking_inquiries_path
      admin_availability_blocks_path
      edit_admin_stay_rule_path
      admin_calendar_imports_path
      admin_journal_posts_path
      admin_content_pages_path
      admin_payment_orders_path
      admin_users_path
    ].each do |route|
      assert_select "a[href='#{send(route)}']", minimum: 1
    end
  end

  test "renders French flash notices inside the admin layout" do
    sign_in_as users(:one)
    inquiry = create_inquiry(status: "new")

    post decline_admin_booking_inquiry_path(inquiry)
    follow_redirect!

    assert_response :success
    assert_select ".admin-flash--notice", text: "Demande refusée : le voyageur est notifié."
  end

  private

  def create_inquiry(status:)
    BookingInquiry.create!(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 3),
      adults: 2,
      children: 0,
      guest_name: "Guest #{status} #{rand(1_000)}",
      email: "guest-#{status}-#{rand(1_000)}@example.com",
      locale: "en",
      status: status
    )
  end
end
