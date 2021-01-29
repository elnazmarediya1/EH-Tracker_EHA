class AddVolHoursToUserEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :user_events, :volunteer_hours, :float, default: 0
  end
end
