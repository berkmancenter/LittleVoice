class CreateItemtypes < ActiveRecord::Migration
  def self.up
    create_table :itemtypes do |t|
      t.string :item_type
      t.timestamps
    end
  end
  
  def self.down
    drop_table :itemtypes
  end
end
