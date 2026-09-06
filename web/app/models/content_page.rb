class ContentPage < ApplicationRecord
  validates :path, :locale, :title, :body_html, presence: true
  validates :path, uniqueness: true, format: { with: /\A(?:fr\/)?[a-z0-9]+(?:-[a-z0-9]+)*(?:\/[a-z0-9]+(?:-[a-z0-9]+)*)*\z/ }
  validates :locale, inclusion: { in: JournalPost::LOCALES }

  scope :published, -> { where(published: true) }

  def to_param
    path
  end
end
