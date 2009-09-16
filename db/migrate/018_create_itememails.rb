class CreateItememails < ActiveRecord::Migration
  def self.up
    create_table :itememails do |t|
      t.integer :item_id
      t.integer :user_id
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :itememails
  end
end
