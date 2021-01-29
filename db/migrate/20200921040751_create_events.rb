class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :date, null: false
      t.string :location, null: false
      t.string :description, null: false
      t.float :points, null: false
      t.float :volunteer_hours, null: false

      t.references :event_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
