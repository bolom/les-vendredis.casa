require "nokogiri"
require "json"

module ContentPages
  class Importer
    CONTENT_ROOT = Rails.root.join("db/content/pages")

    def call
      imported = 0

      ContentPage.transaction do
        source_files.each do |source|
          attributes = parse(source)
          ContentPage.find_or_initialize_by(path: attributes.fetch(:path)).update!(attributes)
          imported += 1
        end
      end

      imported
    end

    private

    def source_files
      Dir[CONTENT_ROOT.join("**/index.html")].sort
    end

    def parse(source)
      document = Nokogiri::HTML(File.read(source))
      relative_path = Pathname(source).relative_path_from(CONTENT_ROOT).dirname.to_s
      locale = document.at_css("html")&.[]("lang") == "fr" ? "fr" : "en"

      {
        path: relative_path,
        locale: locale,
        title: document.at_css("title")&.text.to_s.strip,
        description: meta_content(document, "description"),
        canonical_url: document.at_css('link[rel="canonical"]')&.[]("href"),
        robots: meta_content(document, "robots"),
        alternate_en_url: alternate_url(document, "en"),
        alternate_fr_url: alternate_url(document, "fr"),
        structured_data: JSON.generate(document.css('script[type="application/ld+json"]').map(&:text)),
        body_html: cleaned_body_html(document),
        published: true
      }
    end

    def meta_content(document, name)
      document.at_css("meta[name='#{name}']")&.[]("content")
    end

    def alternate_url(document, language)
      document.at_css("link[rel='alternate'][hreflang='#{language}']")&.[]("href")
    end

    # The preserved Jekyll pages embed layout chrome (top bar, mobile menu,
    # lightbox) that the Rails layout already renders; keeping them would
    # duplicate element ids. Inline gallery handlers become data attributes so
    # the sanitizer can keep the markup strict.
    def cleaned_body_html(document)
      main = document.at_css("main")
      main.css("#top-bar, #lightbox, #mobile-nav, #mobile-nav-overlay").each(&:remove)
      main.css("[onclick]").each do |node|
        if (match = node["onclick"].match(/\AopenLightbox\((\d+)\)\z/))
          node["data-lv-action"] = "open-lightbox"
          node["data-lv-index"] = match[1]
        end
        node.remove_attribute("onclick")
      end
      main.inner_html.to_s.strip
    end
  end
end
