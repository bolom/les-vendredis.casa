require "minitest/autorun"

class AnalyticsStaticTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_static_analytics_allowlist_excludes_pii
    source = File.read(File.join(ROOT, "assets/js/analytics.js"))

    %w[guest_name email phone message public_reference reference check_in check_out].each do |key|
      refute_match(/\b#{Regexp.escape(key)}\b/, source)
    end
  end

  def test_static_analytics_tracks_expected_outbound_events
    source = File.read(File.join(ROOT, "assets/js/analytics.js"))

    %w[click_airbnb click_booking click_email click_whatsapp view_availability select_dates].each do |event|
      assert_includes source, event
    end
  end
end
