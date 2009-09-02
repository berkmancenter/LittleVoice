class RenameRatingactionsRatingtypeidcolumn < ActiveRecord::Migration
  def self.up
    rename_column :ratingactions, :rating_type_id, :ratingtype_id 
  end

  def self.down
    rename_column :ratingactions, :ratingtype_id, :rating_type_id   
  end
end
