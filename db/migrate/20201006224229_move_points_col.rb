class MovePointsCol < ActiveRecord::Migration[6.0]
  def self.up
    add_column :event_types, :points, :float
    remove_column :events, :points
  end

  def self.down
    add_column :events, :points, :float
    remove_column :event_types, :points
  end
end
