class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :rolename
      t.string :functionality
      
      t.timestamps
    end
    Role.create :rolename => "administrator", :functionality => "Handful of SBW staffers with all permissions "
    Role.create :rolename => "moderator", :functionality => "A user with selected permissions involved in maintaining the tone of the community"
    Role.create :rolename => "registered user", :functionality => "Has created and activated (via e-mail confirmation) a user account"
    Role.create :rolename => "banned user", :functionality => "Not able to post on the site or to re-register for the site from the email address used to register for the banned username"
    Role.create :rolename => "restricted posting", :functionality => "Member’s posts are held in queue to be moderated"
    Role.create :rolename => "Google staff", :functionality => "Google staff members"
    Role.create :rolename => "StopBadware staff", :functionality => "StopBadware staff members"
    Role.create :rolename => "Consumer Reports staff", :functionality => "Consumer Reports staff members"
  end
  
  def self.down
    drop_table :roles
  end
end
