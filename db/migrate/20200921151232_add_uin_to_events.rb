class AddUinToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :created_by_uin, :bigint, null: false
  end
end
