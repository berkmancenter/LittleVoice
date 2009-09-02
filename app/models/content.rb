# The file specifies the Content Class and Versioning of Content
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies the content and enables versioning
# of the content


class Content < ActiveRecord::Base
  attr_accessor :content_id
  attr_accessor :live
  validates_uniqueness_of :location
  
  class Version < ActiveRecord::Base
    def parse_body
      self.textile ? RedCloth.new(self.body).to_html : self.body
    end
  end

  def versions
    Content::Version.find_all_by_content_id(self.id).sort_by(&:version).reverse
  end

  def get_version(version_number)
    Content::Version.find_by_content_id_and_version(self.id,version_number)    
  end

  def live_version
    self.versions.first
  end

  def parse_body
    self.textile ? RedCloth.new(self.body).to_html : self.body
  end

  def save_new_version
    most_recent = self.versions.first.version || 0 rescue most_recent = 0
    v = Content::Version.new(self.attributes)
    v.content_id = self.id
    v.version = most_recent + 1
    self.version = v.version + 1
    transaction do
      v.save
      self.save
    end
    return true
  end

  def revert_to_version(version_number)
    if self.versions.collect{|v| v.version }.include? version_number
      self.update_attributes(self.get_version(version_number).attributes)
      self.save
    else
      errors.add_to_base("Version #{version_number} does not exist for Content ID:#{self.id}")
      return false
    end
  end

  def before_destroy
    begin
      self.versions.each do |v|
        v.destroy
      end
    end
  end

end
