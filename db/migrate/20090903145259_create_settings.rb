class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :namespace, :null => false, :default => "LV"
      t.string :key, :null => false
      t.text   :value
      t.timestamps
    end
    add_index :settings, [:namespace, :key], :unique => true
    add_index :settings, [:key, :namespace], :unique => true
  end

  def self.down
    drop_table :settings
  end
end
