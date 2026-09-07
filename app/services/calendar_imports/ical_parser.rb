require "digest"

module CalendarImports
  class IcalParser
    Event = Data.define(:external_uid, :starts_on, :ends_on, :status, :summary, :external_updated_at, :fingerprint)

    def initialize(body)
      @body = body.to_s
    end

    def events
      unfolded.split("BEGIN:VEVENT").drop(1).filter_map do |chunk|
        parse_event(chunk.split("END:VEVENT", 2).first.to_s)
      end
    end

    private

    attr_reader :body

    def unfolded
      body.gsub(/\r\n[ \t]/, "").gsub(/\n[ \t]/, "")
    end

    def parse_event(chunk)
      fields = fields_for(chunk)
      uid = fields["UID"]&.first
      starts_on = parse_date(fields["DTSTART"]&.first)
      ends_on = parse_date(fields["DTEND"]&.first) || starts_on&.+(1.day)
      return if uid.blank? || starts_on.blank? || ends_on.blank?

      status = fields["STATUS"]&.first == "CANCELLED" ? "cancelled" : "confirmed"
      Event.new(
        external_uid: uid,
        starts_on: starts_on,
        ends_on: ends_on,
        status: status,
        summary: fields["SUMMARY"]&.first,
        external_updated_at: parse_datetime(fields["LAST-MODIFIED"]&.first),
        fingerprint: Digest::SHA256.hexdigest([ uid, starts_on, ends_on, status, fields["SUMMARY"]&.first ].join("|"))
      )
    end

    def fields_for(chunk)
      chunk.each_line.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |line, fields|
        key, value = line.strip.split(":", 2)
        next if key.blank? || value.blank?

        fields[key.split(";", 2).first] << value
      end
    end

    def parse_date(value)
      return if value.blank?

      Date.iso8601(value.delete("-")[0, 8].insert(4, "-").insert(7, "-"))
    rescue ArgumentError
      nil
    end

    def parse_datetime(value)
      return if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError
      nil
    end
  end
end
