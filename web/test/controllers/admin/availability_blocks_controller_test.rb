require "test_helper"

module Admin
  class AvailabilityBlocksControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get admin_availability_blocks_path

      assert_redirected_to new_session_path
    end

    test "admin can create manual block reflected in public availability" do
      sign_in_as users(:one)

      post admin_availability_blocks_path, params: {
        availability_block: {
          starts_on: "2026-10-01",
          ends_on: "2026-10-03",
          status: "confirmed",
          summary: "Maintenance"
        }
      }

      assert_redirected_to admin_availability_blocks_path
      get availability_path, params: { from: "2026-10-01", to: "2026-10-02" }
      assert_equal false, response.parsed_body.fetch("days").first.fetch("available")
    end

    test "admin cancels instead of deleting manual block" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      assert_no_difference -> { AvailabilityBlock.count } do
        post cancel_admin_availability_block_path(block)
      end

      assert_equal "cancelled", block.reload.status
    end
  end
end
