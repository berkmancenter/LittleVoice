class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :user_id
      t.integer :itemtype_id
      t.integer :item_mother_id
      t.integer :item_parent_id
      t.string :item_title
      t.text :itemtext
      t.boolean :item_active
      t.timestamps
    end
  end
  
  def self.down
    drop_table :items
  end
end
