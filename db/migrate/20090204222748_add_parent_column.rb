class AddParentColumn < ActiveRecord::Migration
  def self.up
    add_column :ratingitemtotals, :parent_id, :integer
  end
  
  def self.down
    remove_column :ratingitemtotals, :parent_id
  end
end
