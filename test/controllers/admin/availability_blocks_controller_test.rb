require "test_helper"

module Admin
  class AvailabilityBlocksControllerTest < ActionDispatch::IntegrationTest
    test "requires authentication" do
      get admin_availability_blocks_path

      assert_redirected_to new_session_path
    end

    test "admin can block dates without any technical status choice" do
      sign_in_as users(:one)

      assert_difference "AvailabilityBlock.count", 1 do
        post admin_availability_blocks_path, params: {
          availability_block: {
            starts_on: "2026-10-01",
            ends_on: "2026-10-03",
            summary: "Maintenance"
          }
        }
      end

      block = AvailabilityBlock.order(:id).last
      assert_redirected_to admin_calendar_path(month: "2026-10")
      assert_equal "manual_closure", block.kind
      assert_equal "manual", block.source
      assert_equal "confirmed", block.status

      get availability_path, params: { from: "2026-10-01", to: "2026-10-02" }
      assert_equal false, response.parsed_body.fetch("days").first.fetch("available")
    end

    test "block form never exposes status choices and ignores a forged status" do
      sign_in_as users(:one)

      get new_admin_availability_block_path, params: { starts_on: "2026-10-01", ends_on: "2026-10-03" }
      assert_response :success
      assert_select "select[name='availability_block[status]']", count: 0

      post admin_availability_blocks_path, params: {
        availability_block: { starts_on: "2026-10-05", ends_on: "2026-10-06", status: "tentative" }
      }

      assert_equal "confirmed", AvailabilityBlock.order(:id).last.status
    end

    test "admin cancels a manual block instead of deleting it" do
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
      assert_redirected_to admin_calendar_path
      assert_equal "Blocage annulé : ces dates sont de nouveau disponibles.", flash[:notice]
    end

    test "block updates are not routed at all: only cancel remains" do
      sign_in_as users(:one)
      block = AvailabilityBlock.create!(
        starts_on: Date.new(2026, 10, 1),
        ends_on: Date.new(2026, 10, 3),
        kind: "manual_closure",
        source: "manual",
        status: "confirmed"
      )

      patch "/admin/availability_blocks/#{block.id}", params: {
        availability_block: { status: "tentative" }
      }
      assert_includes [ 404, 405 ], response.status

      get admin_availability_blocks_path
      assert_select "form[action='#{cancel_admin_availability_block_path(block)}'] [data-lv-confirm]"
      assert_select "input[name='availability_block[status]']", count: 0
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
  end
end
