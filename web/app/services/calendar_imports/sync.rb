require "net/http"

module CalendarImports
  class Sync
    PROVIDER_ENV = {
      "airbnb" => "AIRBNB_ICAL_URL",
      "booking" => "BOOKING_ICAL_URL"
    }.freeze

    def initialize(calendar_import, fetcher: nil)
      @calendar_import = calendar_import
      @fetcher = fetcher || method(:fetch)
    end

    def call
      started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      events = IcalParser.new(fetcher.call(secret_url)).events

      CalendarEvent.transaction do
        seen = events.map(&:external_uid)
        events.each { |event| upsert_event(event) }
        calendar_import.calendar_events.where.not(external_uid: seen).update_all(status: "cancelled", updated_at: Time.current)
        calendar_import.update!(
          last_synced_at: Time.current,
          last_error_at: nil,
          last_error_message: nil,
          last_status: "success",
          last_duration_ms: duration_ms(started_at),
          last_event_count: events.size
        )
      end
    rescue StandardError => error
      calendar_import.update!(
        last_error_at: Time.current,
        last_error_message: error.message.truncate(500),
        last_status: "failed",
        last_duration_ms: duration_ms(started_at)
      )
      raise
    end

    private

    attr_reader :calendar_import, :fetcher

    def secret_url
      provider = calendar_import.provider.to_sym
      AppConfig.fetch!(PROVIDER_ENV.fetch(calendar_import.provider), :calendars, :"#{provider}_ical_url")
    end

    def fetch(url)
      uri = URI.parse(url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", read_timeout: 10, open_timeout: 5) do |http|
        http.get(uri.request_uri)
      end
      raise "iCal fetch failed with HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def upsert_event(event)
      calendar_event = calendar_import.calendar_events.find_or_initialize_by(external_uid: event.external_uid)
      calendar_event.update!(
        starts_on: event.starts_on,
        ends_on: event.ends_on,
        status: event.status,
        fingerprint: event.fingerprint,
        external_updated_at: event.external_updated_at,
        summary: event.summary
      )
    end

    def duration_ms(started_at)
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
    end
  end
end
