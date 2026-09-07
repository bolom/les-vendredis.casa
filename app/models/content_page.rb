require "json"

class ContentPage < ApplicationRecord
  validates :path, :locale, :title, :body_html, presence: true
  validates :path, uniqueness: true, format: { with: /\A(?:fr\/)?[a-z0-9]+(?:-[a-z0-9]+)*(?:\/[a-z0-9]+(?:-[a-z0-9]+)*)*\z/ }
  validates :locale, inclusion: { in: JournalPost::LOCALES }

  scope :published, -> { where(published: true) }

  def to_param
    path
  end

  def structured_data_blocks
    raw = structured_data.to_s.strip
    return [] if raw.blank?

    parsed = JSON.parse(raw)
    return parsed.map(&:to_s) if parsed.is_a?(Array)

    [ raw ]
  rescue JSON::ParserError
    [ raw ]
  end
end
