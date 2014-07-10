class CreateRatings < ActiveRecord::Migration

  def self.up

    create_table :ratingactions, :force => true do |t|
      t.column :item_id, :integer
      t.column :rating, :boolean, :default => false
      t.column :rating_type_id, :integer, :default => 0, :null => false
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :ratingitemtotals, :force => true do |t|
      t.column :item_id, :integer, :default => 0, :null => false
      t.column :rating_total, :integer, :default => 0, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :ratingtypes, :force => true do |t|
      t.column :rating_type, :string, :null => false
      t.column :rating_value, :integer, :default => 0, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    Ratingtype.create :rating_type => "up", :rating_value => 1
    Ratingtype.create :rating_type => "down", :rating_value => -1
    Ratingtype.create :rating_type => "bad (spam/abuse)", :rating_value => -1
    Ratingtype.create :rating_type => "nuke", :rating_value => -1

  end

  def self.down
    drop_table :ratingactions
    drop_table :ratingitemtotals
    drop_table :ratingtypes
  end

end
