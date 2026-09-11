require "test_helper"

class BookingInquiriesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "creates non blocking inquiry and queues emails" do
    assert_enqueued_jobs 2 do
      post booking_inquiries_path, params: {
        locale: "en",
        booking_inquiry: valid_params
      }
    end

    inquiry = BookingInquiry.last
    assert_redirected_to booking_inquiry_path(inquiry.public_reference)
    assert_equal "new", inquiry.status
    assert_nil inquiry.availability_block
    assert_equal 0, AvailabilityBlock.count
  end

  test "does not save inquiry when dates are no longer available" do
    AvailabilityBlock.create!(
      starts_on: Date.new(2026, 10, 1),
      ends_on: Date.new(2026, 10, 3),
      kind: "manual_closure",
      source: "manual",
      status: "confirmed"
    )

    assert_no_difference -> { BookingInquiry.count } do
      post booking_inquiries_path, params: {
        booking_inquiry: valid_params
      }
    end

    assert_response :unprocessable_entity
  end

  test "honeypot rejects spam without saving" do
    assert_no_difference -> { BookingInquiry.count } do
      post booking_inquiries_path, params: {
        company: "bot",
        booking_inquiry: valid_params
      }
    end

    assert_redirected_to new_booking_inquiry_path(locale: "en")
  end

  test "requires explicit consent on the server" do
    assert_no_difference "BookingInquiry.count" do
      post booking_inquiries_path, params: { booking_inquiry: valid_params.except(:contact_consent) }
    end
    assert_response :unprocessable_entity
  end

  test "French request keeps its language through confirmation" do
    post booking_inquiries_path, params: { locale: "fr", booking_inquiry: valid_params }
    follow_redirect!
    assert_response :success
    assert_includes response.body, "Demande reçue"
    assert BookingInquiry.last.consent_at.present?
  end

  test "accepted French booking keeps its locale and historical price" do
    StayRule.current.update!(nightly_price_eur: 68, airbnb_nightly_price_eur: 71)
    inquiry = create_accepted_inquiry(locale: "fr")
    StayRule.current.update!(nightly_price_eur: 65, airbnb_nightly_price_eur: 70)

    get booking_inquiry_path(inquiry.public_reference)

    assert_response :success
    assert_includes response.body, "8 janvier 2027"
    assert_not_includes response.body, "8 January 2027"
    assert_includes response.body, "136 €"
    assert_includes response.body, "virement bancaire"
    assert_includes response.body, "Montant à régler"
    assert_includes response.body, "au plus tard le "
    assert_includes response.body, "Réservation confirmée"
  end

  test "accepted English booking ignores a conflicting URL locale" do
    inquiry = create_accepted_inquiry(locale: "en")

    get booking_inquiry_path(inquiry.public_reference), params: { locale: "fr" }

    assert_response :success
    assert_includes response.body, "8 January 2027"
    assert_not_includes response.body, "8 janvier 2027"
  end

  private

  def create_accepted_inquiry(locale:)
    inquiry = BookingInquiry.create!(
      check_in: Date.new(2027, 1, 8),
      check_out: Date.new(2027, 1, 10),
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      locale: locale
    )
    inquiry.accept!
    inquiry
  end

  def valid_params
    {
      check_in: "2026-10-01",
      check_out: "2026-10-03",
      adults: 2,
      children: 0,
      guest_name: "Guest",
      email: "guest@example.com",
      phone: "+596696000000",
      message: "Hello",
      contact_consent: "1"
    }
  end
end
