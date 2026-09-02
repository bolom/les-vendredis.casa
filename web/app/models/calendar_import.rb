class CalendarImport < ApplicationRecord
  has_many :calendar_events, dependent: :destroy

  validates :provider, presence: true, uniqueness: true, inclusion: { in: %w[airbnb booking] }
end
