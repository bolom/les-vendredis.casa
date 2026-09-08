module ApplicationHelper
  # Shared with the public content_pages controller: the admin preview must
  # render exactly what the public site will render for the same body_html.
  def sanitized_content_body_html(content_page)
    sanitize(
      content_page.body_html,
      tags: Rails::HTML5::SafeListSanitizer.allowed_tags + %w[section picture source figure figcaption time],
      attributes: Rails::HTML5::SafeListSanitizer.allowed_attributes + %w[
        class id src srcset sizes alt loading width height fetchpriority datetime
        data-availability-url data-email-link data-email-text data-ep-u data-ep-d
        data-lv-action data-lv-index
      ]
    )
  end
end
