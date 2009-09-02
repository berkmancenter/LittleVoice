class AddRawscoreToScores < ActiveRecord::Migration
  def self.up
    rename_column("scores", "total", "rawscore")
    add_column "scores", "award", :integer
  
     logintype = Scoretype.find_by_name('login_score')
     user = User.find_by_login('anonymous')
     Score.create :user_id => user.id, :scoretype_id => logintype.id, :rawscore => 1000, :created_at => Time.new, :updated_at => Time.new}
     
  end

  def self.down
    rename_column("scores", "rawscore", "total")
    remove_column "scores", "award"
  end
end
