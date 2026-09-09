# frozen_string_literal: true

require "test_helper"

# Contract tests for the machine API: bearer auth, permission gating,
# stable JSON errors, and idempotency. Every bug fixed here was first found
# by hand against a real server — these tests keep it from regressing.
#
# Deliberately top-level (not `module Agent`): the app's `Agent` namespace is
# Zeitwerk-managed and would otherwise hijack constant resolution here.
class AgentApiTest < ActionDispatch::IntegrationTest
    setup do
      @token_record, @token = AgentToken.generate!(
        name: "nox",
        permissions: %w[read block_dates cancel_block record_booking accept_booking cancel_booking]
      )
    end

    test "requires a bearer token" do
      get "/agent/house"

      assert_response :unauthorized
      assert_equal "unauthorized", response.parsed_body["error"]
    end

    test "invalid and revoked tokens are rejected" do
      get "/agent/house", headers: auth_header("lv_agent_not_a_token")

      assert_response :unauthorized

      @token_record.revoke!
      get "/agent/house", headers: auth_header(@token)

      assert_response :unauthorized
    end

    test "mutation without the required capability is an explicit 403" do
      _record, read_only = AgentToken.generate!(name: "readonly")

      post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" }, headers: auth_header(read_only)

      assert_response :forbidden
      assert_equal "forbidden", response.parsed_body["error"]
      assert_equal "block_dates", response.parsed_body["missing_permission"]
      assert_no_difference -> { AvailabilityBlock.count } do
        post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" }, headers: auth_header(read_only)
      end
    end

    test "unknown record is a clean json 404, not a 500" do
      get "/agent/booking_requests/999999", headers: auth_header(@token)

      assert_response :not_found
      assert_equal "not_found", response.parsed_body["error"]
    end

    test "block_dates creates a manual closure with a stable json body" do
      post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03", summary: "Maintenance" },
           headers: auth_header(@token)

      assert_response :ok
      block = AvailabilityBlock.order(:id).last
      assert_equal "manual_closure", block.kind
      assert_equal "confirmed", block.status
      assert_equal "Maintenance", block.summary
      result = response.parsed_body["result"].first
      assert_equal block.id, result["id"]
      assert_equal "confirmed", result["status"]
      assert_equal "2026-10-01", result["starts_on"]
    end

    test "overlapping block is a json unprocessable error, never html" do
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1), ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure", source: "manual", status: "confirmed"
      )

      post "/agent/blocks", params: { starts_on: "2026-10-02", ends_on: "2026-10-04" }, headers: auth_header(@token)

      assert_response :unprocessable_entity
      assert_equal "application/json", response.media_type
      assert_equal "error", response.parsed_body["status"]
      assert_match(/overlaps/i, response.parsed_body["error"])
    end

    test "idempotency key replays the stored response without doing the work twice" do
      headers = auth_header(@token).merge("Idempotency-Key" => "qa-key-1")

      post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" }, headers: headers
      assert_response :ok
      first_body = response.parsed_body

      assert_no_difference -> { AvailabilityBlock.count } do
        post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" }, headers: headers
      end
      assert_response :ok
      assert_equal first_body, response.parsed_body
    end

    test "error responses are stored and replayed like successes" do
      blocker = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1), ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure", source: "manual", status: "confirmed"
      )
      headers = auth_header(@token).merge("Idempotency-Key" => "qa-key-2")

      post "/agent/blocks", params: { starts_on: "2026-10-02", ends_on: "2026-10-04" }, headers: headers
      assert_response :unprocessable_entity

      blocker.update!(status: "cancelled")
      assert_no_difference -> { AvailabilityBlock.count } do
        post "/agent/blocks", params: { starts_on: "2026-10-02", ends_on: "2026-10-04" }, headers: headers
      end
      assert_response :unprocessable_entity
      assert_equal "error", response.parsed_body["status"]
    end

    test "idempotency keys are scoped per token" do
      post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" },
           headers: auth_header(@token).merge("Idempotency-Key" => "qa-key-3")
      assert_response :ok

      _other_record, other_token = AgentToken.generate!(name: "other", permissions: %w[read block_dates])
      assert_difference -> { AvailabilityBlock.count }, 1 do
        post "/agent/blocks", params: { starts_on: "2026-10-05", ends_on: "2026-10-07" },
             headers: auth_header(other_token).merge("Idempotency-Key" => "qa-key-3")
      end
      assert_response :ok
    end

    test "a crashed action releases its idempotency key so a retry can run" do
      original_create = AvailabilityBlocks.method(:create)
      AvailabilityBlocks.define_singleton_method(:create) { |**_kwargs| raise "boom" }
      begin
        error = assert_raises(RuntimeError) do
          post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" },
               headers: auth_header(@token).merge("Idempotency-Key" => "qa-key-4")
        end
        assert_equal "boom", error.message
      ensure
        AvailabilityBlocks.define_singleton_method(:create, original_create)
      end

      assert_difference -> { AvailabilityBlock.count }, 1 do
        post "/agent/blocks", params: { starts_on: "2026-10-01", ends_on: "2026-10-03" },
             headers: auth_header(@token).merge("Idempotency-Key" => "qa-key-4")
      end
      assert_response :ok
    end

    test "record_booking stores an agreed stay without blocking dates or emailing the guest" do
      assert_difference -> { BookingInquiry.count }, 1 do
        assert_no_difference -> { AvailabilityBlock.count } do
          post "/agent/booking_requests", params: {
            check_in: "2027-01-08", check_out: "2027-01-10",
            guest_name: "Lou Le Landais", email: "lou.llandais@gmail.com",
            phone: "+590690927149", adults: 2, locale: "fr"
          }, headers: auth_header(@token)
        end
      end

      assert_response :ok
      result = response.parsed_body["result"].last
      inquiry = BookingInquiry.order(:id).last
      assert_equal "new", inquiry.status
      assert_nil inquiry.availability_block_id
      assert_equal "Lou Le Landais", inquiry.guest_name
      assert_equal 2, inquiry.nights
      assert_equal inquiry.public_reference, result["reference"]
    end

    test "record_booking keeps dates that are currently blocked, acceptance re-checks later" do
      AvailabilityBlock.create!(
        starts_on: Date.new(2027, 1, 1), ends_on: Date.new(2027, 12, 31),
        kind: "manual_closure", source: "manual", status: "confirmed"
      )

      post "/agent/booking_requests", params: {
        check_in: "2027-01-08", check_out: "2027-01-10",
        guest_name: "Lou Le Landais", email: "lou.llandais@gmail.com"
      }, headers: auth_header(@token)

      assert_response :ok
      assert_equal "new", BookingInquiry.order(:id).last.status
    end

    test "record_booking notifies the owner but never sends the guest acknowledgement" do
      assert_enqueued_email = -> { ActionMailer::Base.deliveries.size }
      before = assert_enqueued_email.call

      post "/agent/booking_requests", params: {
        check_in: "2027-01-08", check_out: "2027-01-10",
        guest_name: "Lou Le Landais", email: "lou.llandais@gmail.com", locale: "fr"
      }, headers: auth_header(@token)

      assert_response :ok
      events = BookingNotification.order(:id).last(2).map(&:event)
      assert_includes events, "owner_notification"
      assert_not_includes events, "guest_acknowledgement"
      assert_equal before, ActionMailer::Base.deliveries.size
    end

    test "record_booking without the capability is an explicit 403" do
      _record, read_only = AgentToken.generate!(name: "readonly-record")

      assert_no_difference -> { BookingInquiry.count } do
        post "/agent/booking_requests", params: {
          check_in: "2027-01-08", check_out: "2027-01-10",
          guest_name: "Lou", email: "lou@example.com"
        }, headers: auth_header(read_only)
      end
      assert_response :forbidden
      assert_equal "record_booking", response.parsed_body["missing_permission"]
    end

    test "record_booking rejects missing fields and bad dates as json 422" do
      post "/agent/booking_requests", params: { check_in: "2027-01-08", check_out: "2027-01-10" },
           headers: auth_header(@token)
      assert_response :unprocessable_entity
      assert_match(/guest_name is required/, response.parsed_body["error"])

      post "/agent/booking_requests", params: {
        check_in: "2027-01-10", check_out: "2027-01-08",
        guest_name: "Lou", email: "lou@example.com"
      }, headers: auth_header(@token)
      assert_response :unprocessable_entity
      assert_equal "application/json", response.media_type
    end

    test "record_booking is idempotent under the same key" do
      headers = auth_header(@token).merge("Idempotency-Key" => "record-key-1")
      params = {
        check_in: "2027-01-08", check_out: "2027-01-10",
        guest_name: "Lou Le Landais", email: "lou.llandais@gmail.com"
      }

      post "/agent/booking_requests", params: params, headers: headers
      assert_response :ok
      first_body = response.parsed_body

      assert_no_difference -> { BookingInquiry.count } do
        post "/agent/booking_requests", params: params, headers: headers
      end
      assert_response :ok
      assert_equal first_body, response.parsed_body
    end

    private

    def auth_header(token)
      { "Authorization" => "Bearer #{token}" }
    end
end
