
# The file specifies the Subscription Class
#
#
# Author::    
# Copyright:: Copyright (c) 2008 BadwareBusters.org
# License::   Distributes under the same terms as Ruby

# This class specifies Subscription and its associations
class Subscription < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => "#{Subscription.connection.instance_eval{@config[:database]}}.subscriptions_users"
  
  named_scope :tags, :conditions => {:sub_type => "tag"} do
    def by_name(name)
      find(:first, :conditions => {:sub_name => name })
    end
  end
  
  named_scope :items, :conditions => {:sub_type => ["item", "conversation"], :sub_name => nil } do
    def by_id(id)
      find(:first, :conditions => {:sub_type_id => id})
    end
  end
  
  def self.all_conversations
    self.find_or_create_by_sub_type_and_sub_name("item", "all_conversations")
  end
  
  def self.all_items
    self.find_or_create_by_sub_type_and_sub_name("item", "all")
  end
  
  def add_subscriber(user)
    self.users << user if not self.users.include? user
  end
  
  def remove_subscriber(user)
    self.users.delete(user)
  end

  def subscribers
    self.users
  end

  ###
  # Sends notifications to this subscriptions's users for the provided item
  def send_item!(item)
    self.users.each do |user|
      UserMailer.deliver_item_email_me(user, item) if user.enabled
    end
  end
  
end
