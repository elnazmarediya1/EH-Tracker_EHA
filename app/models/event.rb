class Event < ApplicationRecord
  belongs_to :event_type
  has_many :user_events, dependent: :destroy
  has_many :users, through: :user_events
  before_destroy :reduce_points_and_vol_hours, prepend: true

  validates :name, presence: true
  validates :date, presence: true
  validates :location, presence: true
  validates :event_type_id, presence: true
  validates :created_by_uin, presence: true

  scope :active, -> { where(active: true) }
  scope :not_active, -> { where(active: false) }
  scope :expired, -> { where('date < ? and updated_at < ?', 1.week.ago.end_of_day, 1.day.ago.end_of_day) }

  def reduce_points_and_vol_hours
    event_type = self.event_type
    user_events = self.user_events

    user_events.each do |user_event|
      user = user_event.user
      user.update_column(:points, user.points - (event_type.points + user_event.volunteer_hours))
      user.update_column(:volunteer_hours, user.volunteer_hours - user_event.volunteer_hours)
    end
  end
end
