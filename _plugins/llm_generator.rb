# frozen_string_literal: true

require "cgi"
require "fileutils"

module Jekyll
  class LlmGenerator < Generator
    safe true if respond_to?(:safe)
    priority :low

    SITE_URL = "https://lesvendredis.casa"
    AGENT_URL = "https://api.lesvendredis.casa/.well-known/agent.json"
    BOOKING_PATHS = [
      "/come-stay/",
      "/fr/venir-dormir/",
      "/hebergement-insolite-sainte-luce/",
      "/unique-stay-martinique/",
      "/unique-stay-pet-friendly-martinique/",
      "/fr/hebergement-atypique-martinique/",
      "/fr/hebergement-atypique-animal-accepte-martinique/"
    ].freeze

    def generate(site)
      write_global_llm(site)

      documents(site).each do |document|
        next unless document.output_ext == ".html"
        next unless document.url && document.url.end_with?("/")

        write_page_llm(site, document)
      end
    end

    private

    def documents(site)
      (site.pages + site.posts.docs).reject { |document| excluded?(document) }
    end

    def excluded?(document)
      document.url.nil? || document.url == "/llm.txt" || document.url == "/" || document.data["sitemap"] == false
    end

    def write_global_llm(site)
      lines = [
        "# Les Vendredis",
        "URL: #{SITE_URL}/",
        "Description: Handmade A-frame cabin with private garden in Sainte-Luce, Martinique.",
        "Price: 80 EURC / night — Max 3 guests",
        "",
        "## Pages"
      ]

      documents(site)
        .select { |document| document.output_ext == ".html" && document.url&.end_with?("/") }
        .sort_by(&:url)
        .each do |document|
          lines << "- #{absolute_url(document.url)} — #{title(document)}"
        end

      lines += [
        "",
        "## Booking API",
        "Agent metadata: GET #{AGENT_URL}",
        ""
      ]

      content = lines.join("\n")
      write(site, "llm.txt", content)
      write(site, ".well-known/llms.txt", content)
    end

    def write_page_llm(site, document)
      lines = [
        "# #{title(document)}",
        "URL: #{absolute_url(document.url)}",
        "Lang: #{document.data["lang"] || site.config["lang"] || "en"}",
        ""
      ]

      if booking_page?(document)
        lines += booking_content(document)
      else
        lines += content_summary(document)
      end

      path = File.join(document.url.delete_prefix("/"), "llm.txt")
      write(site, path, lines.join("\n"))
    end

    def booking_page?(document)
      document.data["llm_booking"] == true || BOOKING_PATHS.include?(document.url)
    end

    def booking_content(document)
      [
        "## About this page",
        summary(document),
        "",
        "## The stay",
        "Price: 80 EURC / night (Polygon mainnet)",
        "Max guests: 3",
        "Min nights: 1 — Max nights: 21",
        "Advance booking: 21 days minimum",
        "Preparation days between bookings: 2",
        "Features: air conditioning, private garden, pet-friendly",
        "",
        "## Book via autonomous agent (x402)",
        "",
        "Agent metadata: GET #{AGENT_URL}",
        "",
        "GET /rules",
        "  Returns: minNights, maxNights, minAdvanceDays, maxGuests, preparationDays, price",
        "",
        "GET /availability?from=YYYY-MM-DD&to=YYYY-MM-DD",
        "  Returns: list of days with available: true/false, price, currency, rules",
        "",
        "POST /quote",
        "  Body: { \"date\": \"YYYY-MM-DD\", \"nights\": 2, \"guests\": 2 }",
        "  Returns: totalPrice, checkOut, currency, network, asset, payTo, expiresAt",
        "",
        "POST /book  [x402 payment required — EURC on Polygon mainnet]",
        "  Body: { \"date\": \"YYYY-MM-DD\", \"nights\": 2, \"guests\": 2 }",
        "  Payment: exact scheme, 80 EURC per night × nights",
        "  Returns: bookingId, date, checkOut, guests, nights, price, network",
        "",
        "GET /booking/:id",
        "  Returns: booking status and details",
        "",
        "POST /booking/:id/cancel",
        "  Returns: { cancelled: true, bookingId }",
        "",
        "GET /calendar.ics",
        "  Returns: iCal export of all confirmed bookings",
        ""
      ]
    end

    def content_summary(document)
      [
        "## Content",
        summary(document),
        "",
        "## Book the A-frame",
        "Agent metadata: GET #{AGENT_URL}",
        ""
      ]
    end

    def summary(document)
      value = document.data["description"] || document.data["summary"] || plain_text(document.content)
      plain_text(value.to_s).split(/\s+/).first(120).join(" ")
    end

    def title(document)
      document.data["title"] || document.basename_without_ext || "Untitled"
    end

    def plain_text(content)
      content
        .gsub(/\{%.*?%\}/m, " ")
        .gsub(/\{\{.*?\}\}/m, " ")
        .gsub(/!\[[^\]]*\]\([^\)]*\)/, " ")
        .gsub(/\[([^\]]+)\]\([^\)]*\)/, "\\1")
        .gsub(/<script\b.*?<\/script>/mi, " ")
        .gsub(/<style\b.*?<\/style>/mi, " ")
        .gsub(/<[^>]+>/, " ")
        .then { |text| CGI.unescapeHTML(text) }
        .gsub(/\s+/, " ")
        .strip
    end

    def absolute_url(path)
      "#{SITE_URL}#{path}"
    end

    def write(site, relative_path, content)
      destination = File.join(site.dest, relative_path)
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, content)
      site.keep_files << relative_path
    end
  end
end
