require "builder"

class DiscoveryController < ApplicationController
  allow_unauthenticated_access

  SITE_URL = "https://lesvendredis.casa".freeze

  def sitemap_index
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.sitemapindex(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
      %w[/sitemap.xml /fr/sitemap.xml].each do |path|
        xml.sitemap { xml.loc "#{SITE_URL}#{path}" }
      end
    end
    render xml: xml.target!
  end

  def sitemap
    locale = params[:locale] == "fr" ? "fr" : "en"
    prefix = locale == "fr" ? "/fr" : ""
    entries = [ [ "#{prefix}/", nil ], [ "#{prefix}/journal/", nil ] ]
    ContentPage.published.where(locale: locale).find_each do |page|
      next if page.robots.to_s.match?(/\bnoindex\b/i)
      entries << [ "/#{page.path}/", page.updated_at ]
    end
    JournalPost.published.where(locale: locale).find_each do |post|
      entries << [ "#{prefix}/journal/#{post.slug}/", post.updated_at ]
    end
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
      entries.each do |path, updated_at|
        xml.url do
          xml.loc "#{SITE_URL}#{path}"
          xml.lastmod updated_at.iso8601 if updated_at
        end
      end
    end
    render xml: xml.target!
  end

  def feed
    posts = JournalPost.published.recent_first.limit(50)
    xml = Builder::XmlMarkup.new
    xml.instruct!
    xml.feed(xmlns: "http://www.w3.org/2005/Atom") do
      xml.id "#{SITE_URL}/"
      xml.title "Les Vendredis — Journal"
      xml.link(href: "#{SITE_URL}/feed.xml", rel: "self")
      xml.link(href: "#{SITE_URL}/journal/")
      xml.updated((posts.map(&:updated_at).max || Time.utc(2022)).iso8601)
      xml.author { xml.name "Les Vendredis" }
      posts.each do |post|
        url = "#{SITE_URL}#{post.locale == 'fr' ? '/fr' : ''}/journal/#{post.slug}/"
        xml.entry do
          xml.id url
          xml.title post.title
          xml.link(href: url)
          xml.published post.published_on.to_time.utc.iso8601
          xml.updated post.updated_at.iso8601
          xml.summary post.summary.to_s
        end
      end
    end
    render body: xml.target!, content_type: "application/atom+xml"
  end

  def llms
    render plain: <<~TEXT, content_type: "text/plain"
      # Les Vendredis

      A-frame cabin rental in Sainte-Luce, Martinique. Direct booking is handled by this Rails application.

      ## Machine Booking API

      Base URL: #{SITE_URL}

      - GET /rules — stay rules, capacity, price, currency, network, asset, recipient.
      - GET /availability?from=YYYY-MM-DD&to=YYYY-MM-DD — available nights with price metadata.
      - POST /quote — JSON body: {"date":"YYYY-MM-DD","nights":2,"guests":2}
      - POST /book — returns HTTP 402 with x402 payment challenge when payment is required.

      Booking is not confirmed until payment verification succeeds. If paymentConfigured is false, the payment recipient is not configured yet.
    TEXT
  end

  def agent
    render json: {
      name: "Les Vendredis",
      description: "A-frame cabin rental in Sainte-Luce, Martinique.",
      url: SITE_URL,
      provides: [ "short_term_rental" ],
      contact: {
        email: "hello@lesvendredis.casa",
        whatsapp: "+596696969699"
      },
      api: {
        rules: "#{SITE_URL}/rules",
        availability: "#{SITE_URL}/availability",
        quote: "#{SITE_URL}/quote",
        book: "#{SITE_URL}/book"
      },
      x402: {
        version: "1.0",
        network: MachineBookings::Quote.network,
        chainId: MachineBookings::Quote.chain_id,
        asset: MachineBookings::Quote.asset,
        currency: MachineBookings::Quote.currency,
        payTo: MachineBookings::Quote.pay_to,
        paymentConfigured: MachineBookings::Quote.pay_to.present?
      }
    }
  end
end
