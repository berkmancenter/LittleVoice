class AddNestedsetColumns < ActiveRecord::Migration
  def self.up
    add_column :items, :lft, :int
    add_column :items, :rgt, :int
  end

  def self.down
    remove_column :items, :lft
    remove_column :items, :rgt
  end
end
