class CreateReputations < ActiveRecord::Migration
  def self.up
    create_table :reputations do |t|
      t.integer :user_id
      t.integer :rawscore
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :reputations
  end
end
