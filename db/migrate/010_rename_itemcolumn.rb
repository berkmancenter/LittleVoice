class RenameItemcolumn < ActiveRecord::Migration
  def self.up
    rename_column :items, :item_mother_id, :item_root_id 
  end

  def self.down
    rename_column :items, :item_root_id, :item_mother_id 
  end
end
