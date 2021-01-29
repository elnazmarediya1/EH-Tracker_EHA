class RemoveVolHoursFromEvents < ActiveRecord::Migration[6.0]
  def self.up
    remove_column :events, :volunteer_hours
  end

  def self.down
    add_column :events, :volunteer_hours, :float
  end
end
