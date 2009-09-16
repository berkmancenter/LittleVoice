class AddRawscoreToScores < ActiveRecord::Migration
  def self.up
    rename_column("scores", "total", "rawscore")
    add_column "scores", "award", :integer
    
  end
  
  def self.down
    rename_column("scores", "rawscore", "total")
    remove_column "scores", "award"
  end
end
