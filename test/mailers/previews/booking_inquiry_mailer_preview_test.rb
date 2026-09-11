require "test_helper"

class BookingInquiryMailerPreviewTest < ActionMailer::TestCase
  setup do
    @preview = BookingInquiryMailerPreview.new
  end

  test "previews build in-memory inquiries that are never persisted" do
    preview_actions.each do |action|
      mail = @preview.public_send(action)
      assert_not_nil mail.message
    end

    assert_not BookingInquiry.exists?(email: "camille@example.com")
  end

  test "all preview actions render without raising" do
    preview_actions.each do |action|
      mail = @preview.public_send(action)
      assert_not_nil mail.subject
      assert mail.multipart?, "expected multipart email for #{action}"
      assert mail.text_part.body.decoded.present?
      assert mail.html_part.body.decoded.present?
    end
  end

  test "guest acceptance preview covers both locales" do
    english = @preview.guest_acceptance
    french = @preview.guest_acceptance_fr

    assert_match "is confirmed", english.subject
    assert_match "est confirmé", french.subject
    assert_match "locale=en", english.html_part.body.decoded
    assert_match "locale=fr", french.html_part.body.decoded
  end

  private

  def preview_actions
    @preview.class.public_instance_methods(false)
  end
end
