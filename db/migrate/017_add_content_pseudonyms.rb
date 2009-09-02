class AddContentPseudonyms < ActiveRecord::Migration
  def self.up
    add_column :contents, :pseudonym, :string
    add_column :content_versions, :pseudonym, :string
  end

  def self.down
    remove_column :contents, :pseudonym
    remove_column :content_versions, :pseudonym
  end
end
