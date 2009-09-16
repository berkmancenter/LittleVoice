class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.text :body
      t.string :controller, :action, :name, :location
      t.integer :version
      t.boolean :textile
      t.timestamps
    end
    
    create_table :content_versions do |t|
      t.integer :content_id
      t.text :body
      t.string :controller, :action, :name, :location
      t.integer :version
      t.boolean :textile, :live
      t.timestamps
    end
  end
  
  def self.down
    drop_table :contents
    drop_table :content_versions
  end
end
