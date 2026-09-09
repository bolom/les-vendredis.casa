module CalendarExports
  class Ical
    HEADER = [
      "BEGIN:VCALENDAR",
      "PRODID:-//Les Vendredis//Availability Export//EN",
      "VERSION:2.0",
      "CALSCALE:GREGORIAN",
      "METHOD:PUBLISH",
      "X-WR-CALNAME:Les Vendredis - Unavailable"
    ].freeze

    def call
      lines = HEADER + blocks.flat_map { |block| event_lines(block) } + [ "END:VCALENDAR" ]
      "#{lines.join("\r\n")}\r\n"
    end

    private

    def blocks
      AvailabilityBlock.blocking.where(source: %w[direct manual]).order(:starts_on, :id)
    end

    def event_lines(block)
      [
        "BEGIN:VEVENT",
        "UID:availability-block-#{block.id}@lesvendredis.casa",
        "DTSTAMP:#{block.updated_at.utc.strftime("%Y%m%dT%H%M%SZ")}",
        "DTSTART;VALUE=DATE:#{block.starts_on.strftime("%Y%m%d")}",
        "DTEND;VALUE=DATE:#{block.ends_on.strftime("%Y%m%d")}",
        "SUMMARY:Unavailable",
        "TRANSP:OPAQUE",
        "END:VEVENT"
      ]
    end
  end
end
