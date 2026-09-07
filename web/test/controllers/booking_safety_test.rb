require "test_helper"

class BookingSafetyTest < ActionDispatch::IntegrationTest
  test "rate limits inquiry spam before saving or sending" do
    assert_no_difference [ "BookingInquiry.count", "BookingNotification.count" ] do
      10.times { post booking_inquiries_path, params: { company: "bot" } }
      post booking_inquiries_path, params: { company: "bot" }
      assert_response :too_many_requests
    end
  end

  test "quote throttles excessive requests" do
    60.times { post "/quote", params: { date: "invalid" }, as: :json }
    post "/quote", params: { date: "invalid" }, as: :json
    assert_response :too_many_requests
  end

  test "sensitive request values are filtered" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    values = %w[guest_name phone message check_in check_out payment_signature authorization quote_id].index_with { "sensitive" }
    assert filter.filter(values).values.all? { |value| value == "[FILTERED]" }
  end

  test "French validation contains actionable French text" do
    post booking_inquiries_path, params: { locale: "fr", booking_inquiry: { guest_name: "", contact_consent: "0" } }
    assert_response :unprocessable_entity
    assert_includes response.body, "Acceptez d’être contacté"
    assert_includes response.body, "Indiquez votre nom"
  end
end
