class AddVolunteerHoursToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :volunteer_hours, :float, default: 0
  end
end
