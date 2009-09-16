class CreateScores < ActiveRecord::Migration
  def self.up
    create_table :scores do |t|
      t.integer :user_id, :item_id, :scoretype_id, :total
      t.timestamps
    end
    
  end
  
  def self.down
    drop_table :scores
  end
end
