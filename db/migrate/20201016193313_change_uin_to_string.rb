class ChangeUinToString < ActiveRecord::Migration[6.0]
  def self.up
    change_table :users do |t|
      t.change :uin, :string
    end
  end

  def self.down
    change_table :users do |t|
      t.change :uin, :bigint
    end
  end
end
