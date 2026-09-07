class JournalPost < ApplicationRecord
  LOCALES = %w[en fr].freeze

  validates :title, :slug, :locale, :body_markdown, :published_on, presence: true
  validates :locale, inclusion: { in: LOCALES }
  validates :slug, uniqueness: { scope: :locale }, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/ }

  scope :published, -> { where(published: true).where(published_on: ..Date.current) }
  scope :recent_first, -> { order(published_on: :desc, id: :desc) }

  def to_param
    slug
  end
end
