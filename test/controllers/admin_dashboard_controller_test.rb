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
    assert_select "h1", "Accueil"
  end

  test "lists upcoming arrivals and departures in human language" do
    sign_in_as users(:one)
    AvailabilityBlock.create!(
      starts_on: 3.days.from_now.to_date,
      ends_on: 6.days.from_now.to_date,
      kind: "direct_stay",
      source: "direct",
      status: "confirmed",
      summary: "Séjour direct LV-TEST"
    )

    get admin_root_path

    assert_select "h2", text: "Prochaines arrivées"
    assert_select "h2", text: "Prochains départs"
    assert_select ".admin-task-list li", text: /arrive le/
    assert_select ".admin-task-list li", text: /part le/
    assert_select ".admin-task-list li", text: /Séjour direct LV-TEST/
  end

  test "upcoming stays include imported platform reservations with their platform label" do
    sign_in_as users(:one)
    imported = CalendarImport.create!(provider: "booking")
    CalendarEvent.create!(
      calendar_import: imported,
      external_uid: "evt-dash-1",
      starts_on: 5.days.from_now.to_date,
      ends_on: 8.days.from_now.to_date,
      status: "confirmed",
      fingerprint: "fp-dash-1",
      summary: "Plateforme LV-TEST"
    )

    get admin_root_path

    assert_select ".admin-task-list li", text: /Plateforme LV-TEST/, count: 2
    assert_select ".admin-task-list li", text: /Booking\.com/
  end

  test "manual closures never appear as upcoming arrivals or departures" do
    sign_in_as users(:one)
    AvailabilityBlock.create!(
      starts_on: 2.days.from_now.to_date,
      ends_on: 4.days.from_now.to_date,
      kind: "manual_closure",
      source: "manual",
      status: "confirmed",
      summary: "Peinture maison"
    )

    get admin_root_path

    assert_select ".admin-task-list li", text: /Peinture maison/, count: 0
    assert_select "p.admin-definition", text: "Aucune arrivée dans les 14 prochains jours."
    assert_select "p.admin-definition", text: "Aucun départ dans les 14 prochains jours."
  end

  test "lists inquiries to handle with their received age" do
    sign_in_as users(:one)
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 3),
      adults: 2,
      guest_name: "Marie Dupont",
      email: "marie@example.com",
      locale: "en"
    )

    get admin_root_path

    assert_select ".admin-task-list li", text: /Marie Dupont/
    assert_select "a[href='#{admin_booking_inquiry_path(inquiry)}']", text: "Traiter"
  end

  test "shows external calendar states with sync shortcuts" do
    sign_in_as users(:one)
    CalendarImport.ensure_defaults!
    CalendarImport.find_by(provider: "airbnb").update!(last_status: "success", last_synced_at: 4.minutes.ago)

    get admin_root_path

    assert_select ".admin-state--ok", text: /À jour · synchronisé il y a 4 min/
    assert_select ".admin-state--problem", minimum: 1
    assert_select "form[action='#{sync_admin_calendar_import_path(CalendarImport.find_by(provider: "airbnb"))}'] [data-lv-confirm]"
  end

  test "offers house shortcuts and does not show technical counters" do
    sign_in_as users(:one)
    PaymentOrder.create!(
      public_id: "0f0e0d0c-aaaa-bbbb-cccc-444455556666",
      quote: { totalPrice: "148" }.as_json,
      requirements: { scheme: "exact" }.as_json,
      expires_at: 15.minutes.from_now,
      status: "review"
    )
    JournalPost.create!(title: "Brouillon", slug: "brouillon", locale: "fr", body_markdown: "x", published_on: Date.current, published: false)

    get admin_root_path

    assert_select "a[href='#{new_admin_availability_block_path}']", text: "Bloquer des dates"
    assert_select "a[href='#{admin_calendar_path}']", minimum: 1
    assert_select ".admin-counter", count: 0
    assert_select "form[action='#{admin_payment_order_path(PaymentOrder.last)}']", count: 0
    assert_select "*", text: /articles du journal en brouillon/, count: 0
  end

  test "navigation is split into house and technical zones" do
    sign_in_as users(:one)

    get admin_root_path

    assert_select "nav[aria-label='Gestion de la maison']" do |nav|
      assert_select nav, "a[href='#{admin_calendar_path}']"
      assert_select nav, "a[href='#{admin_booking_inquiries_path}']"
      assert_select nav, "a[href='#{edit_admin_stay_rule_path}']"
      assert_select nav, "a[href='#{admin_journal_posts_path}']"
      assert_select nav, "a[href='#{admin_content_pages_path}']", count: 0
      assert_select nav, "a[href='#{admin_payment_orders_path}']", count: 0
      assert_select nav, "a[href='#{admin_users_path}']", count: 0
    end
    assert_select "nav[aria-label='Section technique']" do |nav|
      assert_select nav, "a[href='#{admin_payment_orders_path}']"
      assert_select nav, "a[href='#{admin_users_path}']"
      assert_select nav, "a[href='#{admin_content_pages_path}']"
      assert_select nav, "a[href='#{admin_diagnostics_path}']"
      assert_select nav, "a[href='#{admin_notifications_path}']"
    end
    assert_select "button.admin-nav-toggle"
  end

  test "payments live in the technical zone only" do
    sign_in_as users(:two)

    get admin_root_path

    assert_select "nav[aria-label='Gestion de la maison'] a[href='#{admin_payment_orders_path}']", count: 0
    assert_select "nav[aria-label='Section technique']", count: 0
    assert_select "button.admin-nav-toggle", count: 0
  end

  test "renders French flash notices inside the admin layout" do
    sign_in_as users(:one)
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2026, 10, 1),
      check_out: Date.new(2026, 10, 3),
      adults: 2,
      guest_name: "Guest",
      email: "guest@example.com",
      locale: "en"
    )

    post decline_admin_booking_inquiry_path(inquiry)
    follow_redirect!

    assert_response :success
    assert_select ".admin-flash--notice", text: "Demande refusée : le voyageur est notifié."
  end
end
