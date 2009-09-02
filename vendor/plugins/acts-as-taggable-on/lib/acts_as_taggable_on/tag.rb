class Tag < ActiveRecord::Base  
  has_many :taggings
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  def self.cleanup(name)
    regexp = /[^a-z0-9_-]+:\u+/
    n = name.chars.downcase.gsub(regexp, '').strip
    n.blank? ? nil : n
  end
  
  def name=(name)
    #strip any non-alphanumeric and downcase
    self["name"] = Tag.cleanup(name)
  end
  
  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    name = Tag.cleanup(name)
    
    begin
      find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
    rescue ActiveRecord::StatementInvalid
      # If we can't insert the tag (perhaps a dupe), try to refetch.
      find(:first, :conditions => ["name LIKE ?", name])
    end
  end
  
  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end
  
  def to_s
    name
  end
  
  def count    
    read_attribute(:count).to_i
  end
  
  def self.per_page
    10
  end
end
