class UserEvent < ApplicationRecord
  belongs_to :event
  belongs_to :user

  validates :volunteer_hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id,
            uniqueness: { scope: :event_id, message: 'has already registered for this event' }
end
