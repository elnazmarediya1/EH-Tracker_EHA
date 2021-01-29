class EventType < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :name, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
