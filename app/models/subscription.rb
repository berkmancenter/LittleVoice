
# The file specifies the Subscription Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Subscription and its associations
class Subscription < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "subscriptions_users"

  named_scope :tags, :conditions => {:sub_type => "tag"} do
    def by_name(name)
      find(:first, :conditions => {:sub_name => name })
    end
  end
  
  named_scope :items, :conditions => {:sub_type => "item", :sub_name => nil } do
    def by_id(id)
      find(:first, :conditions => {:sub_type_id => id})
    end
  end
  
  def self.all_conversations
    self.find(:first, :conditions => {:sub_type => "item", :sub_name => "all_conversations"})
  end
  
  def self.all_items
    self.find(:first, :conditions => {:sub_type => "item", :sub_name => "all"})
  end
  
  def add_subscriber(user)
    self.users << user if not self.users.include? user
  end
  
  
end
