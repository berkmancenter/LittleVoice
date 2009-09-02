class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :sub_type, :sub_name
      t.integer :sub_type_id
    end
    
    #Create default subscription types for all conversations or items
    Subscription.create(:sub_type => "item", :sub_name => "all_conversations")
    Subscription.create(:sub_type => "item", :sub_name => "all")
    
    #Generate subscriptions for any pre-existing items
    Item.find(:all).each {|item| item.update_subscriptions }
    
    create_table :subscriptions_users, :id => false do |t|
      t.integer :subscription_id, :user_id
    end
    
    #Convert itememails to subscriptions
    Itememail.find(:all).each do |itememail|
      Subscription.items.by_id(itememail.item_id).add_subscriber(User.find(itememail.user_id))
    end
    
  end

  def self.down
    drop_table :subscriptions_users
    drop_table :subscriptions
  end
end
