class AddLevelsToRatingactions < ActiveRecord::Migration
  def self.up
    add_column "ratingactions", "user_level", :integer
  end
  
  def self.down
    remove_column "ratingactions", "user_level"
  end
end
