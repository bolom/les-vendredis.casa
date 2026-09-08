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

    test "admin cannot move a direct stay through the generic form" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "direct_stay",
        source: "direct",
        status: "tentative"
      )

      patch admin_availability_block_path(block), params: {
        availability_block: { status: "confirmed" }
      }

      assert_response :unprocessable_entity
      assert_equal "tentative", block.reload.status
    end

    test "admin can still edit a manual block" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      patch admin_availability_block_path(block), params: {
        availability_block: { status: "tentative", summary: "Plumbing" }
      }

      assert_redirected_to admin_availability_blocks_path
      assert_equal "tentative", block.reload.status
    end

    test "admin can filter blocks by status" do
      sign_in_as users(:one)
      AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed",
        summary: "Peinture"
      )

      get admin_availability_blocks_path, params: { status: "confirmed" }
      assert_select "td", text: /Peinture/

      get admin_availability_blocks_path, params: { status: "tentative" }
      assert_select "td", text: /Peinture/, count: 0
    end

    test "cancel asks for confirmation" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      get admin_availability_blocks_path

      assert_select "form[action='#{cancel_admin_availability_block_path(block)}'] [data-lv-confirm]"
    end
  end
end
