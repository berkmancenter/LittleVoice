class CreateScoretypes < ActiveRecord::Migration
  def self.up
    create_table :scoretypes do |t|
      t.string :name, :limit => 20
      t.integer :award, :version
      t.string :description
      t.timestamps
    end
    
    Scoretype.create :name => "pos_score", :award => 1000, :description => "every message with a net positive community rating!", :version => 1
    Scoretype.create :name => "login_score", :award => 100, :description => "every week (or 7-day period) in which a user logs in", :version => 1
    Scoretype.create :name => "vote_score", :award => 200, :description => "every week (or 7-day period) in which a user votes on a message", :version => 1
    Scoretype.create :name => "neg_score", :award => -2000, :description => "every message with a net negative community rating", :version => 1
    Scoretype.create :name => "nuke_score", :award => -500, :description => "every message that was actively nuked by a moderator (passive nukage is a metaphysical impossibility)", :version => 1
    Scoretype.create :name => "unnuke_score", :award => 500, :description => "every message that was actively de-nukified by a moderator", :version => 1
    Scoretype.create :name => "adjust_score", :award => 0, :description => "adjustments made by the administrator", :version => 1
    
  end
  
  def self.down
    drop_table :scoretypes
  end
end
