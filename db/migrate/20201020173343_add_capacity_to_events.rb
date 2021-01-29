class AddCapacityToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :max_capacity, :integer
  end
end
