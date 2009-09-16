class RenameItemparentcolumn < ActiveRecord::Migration
  def self.up
    rename_column :items, :item_parent_id, :parent_id 
  end
  
  def self.down
    rename_column :items, :parent_id, :item_parent_id
  end
end
