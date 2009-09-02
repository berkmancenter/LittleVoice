# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090728132505) do

  
  create_table "content_versions", :force => true do |t|
    t.integer  "content_id", :limit => 4
    t.text     "body"
    t.string   "controller"
    t.string   "action"
    t.string   "name"
    t.string   "location"
    t.integer  "version",    :limit => 4
    t.boolean  "textile"
    t.boolean  "live"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pseudonym"
  end

  create_table "contents", :force => true do |t|
    t.text     "body"
    t.string   "controller"
    t.string   "action"
    t.string   "name"
    t.string   "location"
    t.integer  "version",    :limit => 4
    t.boolean  "textile"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pseudonym"
  end

  create_table "invitations", :force => true do |t|
    t.string   "user_id"
    t.string   "email"
    t.string   "code"
    t.boolean  "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "itememails", :force => true do |t|
    t.integer  "item_id",    :limit => 4
    t.integer  "user_id",    :limit => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "user_id",      :limit => 4
    t.integer  "itemtype_id",  :limit => 4
    t.integer  "item_root_id", :limit => 4
    t.integer  "parent_id",    :limit => 4
    t.integer  "subcategory_item_id",    :limit => 4
    t.string   "item_title"
    t.text     "itemtext"
    t.boolean  "item_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lft",          :limit => 4
    t.integer  "rgt",          :limit => 4
  end

  create_table "itemtypes", :force => true do |t|
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :limit => 4, :null => false
    t.integer  "user_id",    :limit => 4, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratingactions", :force => true do |t|
    t.integer  "item_id",       :limit => 4
    t.boolean  "rating",                     :default => false
    t.integer  "ratingtype_id", :limit => 4, :default => 0,     :null => false
    t.integer  "user_id",       :limit => 4, :default => 0,     :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "user_level",    :limit => 4
  end

  create_table "ratingitemtotals", :force => true do |t|
    t.integer  "item_id",      :limit => 4, :default => 0, :null => false
    t.integer  "rating_total", :limit => 4, :default => 0, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "parent_id",    :limit => 4
  end

  create_table "ratingtypes", :force => true do |t|
    t.string   "rating_type",                              :null => false
    t.integer  "rating_value", :limit => 4, :default => 0, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "reputations", :force => true do |t|
    t.integer  "user_id",    :limit => 4
    t.integer  "rawscore",   :limit => 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "rolename"
    t.string   "functionality"
    t.datetime "created_at"
    t.datetime "updated_at"
   
  end

  create_table "scores", :force => true do |t|
    t.integer  "user_id",      :limit => 4
    t.integer  "item_id",      :limit => 4
    t.integer  "scoretype_id", :limit => 4
    t.integer  "rawscore",     :limit => 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "award",        :limit => 4
  end

  create_table "scoretypes", :force => true do |t|
    t.string   "name",        :limit => 20
    t.integer  "award",       :limit => 4
    t.integer  "version",     :limit => 4
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "site_configs", :force => true do |t|
    t.string "site_name",  :default => "Site Name", :null => false
    t.string "org_name",  :default => "Organisation Name", :null => false
    t.string "site_url",  :default => "127.0.0.1", :null => false
    t.string "org_url",  :default => "example.org", :null => false
    t.string "rcc_pub" 
    t.string "rcc_priv" 
    t.string "site_logo_url", :default => "/images/site-logo.png", :null => false
    t.string "org_logo_url",  :default => "/images/org-logo.png", :null => false
    t.string "m_server_addr"
    t.integer "m_server_port"
    t.string "m_server_domain"
    t.integer "deleted", :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.string  "sub_type"
    t.string  "sub_name"
    t.integer "sub_type_id", :limit => 4
  end

  create_table "subscriptions_users", :id => false, :force => true do |t|
    t.integer "subscription_id", :limit => 4
    t.integer "user_id",         :limit => 4
  end

  create_table "survey_responses", :force => true do |t|
    t.string "survey_name"
    t.binary "responses"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :limit => 4
    t.integer  "taggable_id",   :limit => 4
    t.integer  "tagger_id",     :limit => 4
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    
  end
  
  #creatgin default site Config
  config = SiteConfig.new
  config.save

    #creating the roles
    Role.create :rolename => "administrator", :functionality => "Administrator with all permissions "
    Role.create :rolename => "moderator", :functionality => "A user with selected permissions involved in maintaining the tone of the community"
    Role.create :rolename => "registered user", :functionality => "Has created and activated (via e-mail confirmation) a user account"
    Role.create :rolename => "banned user", :functionality => "Not able to post on the site or to re-register for the site from the email address used to register for the banned username"
    Role.create :rolename => "restricted posting", :functionality => "Member’s posts are held in queue to be moderated"

    
    # Creating Default Users
    # *User* :: _password_
    # admin  :: admin12
    # mod  :: mod12
    # reguser  :: reguser12
    User.create :login => 'admin', :email => 'admin@abcxyz.com', :password => 'admin12', :password_confirmation =>'admin12'
    Permission.create :role_id => 1, :user_id => 1, :created_at => Time.new, :updated_at => Time.new
    User.create :login => 'mod', :email => 'mod@abcxyz.com', :password => 'mod12', :password_confirmation =>'mod12'
    Permission.create :role_id => 2, :user_id => 2, :created_at => Time.new, :updated_at => Time.new
    User.create :login => 'reguser', :email => 'reguser@abcxyz.com', :password => 'reguser12', :password_confirmation =>'reguser12'
    Permission.create :role_id => 3, :user_id => 3, :created_at => Time.new, :updated_at => Time.new

    #activatiing all the users
    User.find(:all).each { |user|   
      user.activated_at = Time.new
      user.activation_code = nil
      user.save
    }
    
    #Creating Scoretypes
    Scoretype.create :name => "pos_score", :award => 1000, :description => "every message with a net positive community rating!", :version => 1
    Scoretype.create :name => "login_score", :award => 100, :description => "every week (or 7-day period) in which a user logs in", :version => 1
    Scoretype.create :name => "vote_score", :award => 200, :description => "every week (or 7-day period) in which a user votes on a message", :version => 1
    Scoretype.create :name => "neg_score", :award => -2000, :description => "every message with a net negative community rating", :version => 1
    Scoretype.create :name => "nuke_score", :award => -500, :description => "every message that was actively nuked by a moderator (passive nukage is a metaphysical impossibility)", :version => 1
    Scoretype.create :name => "unnuke_score", :award => 500, :description => "every message that was actively de-nukified by a moderator", :version => 1
    Scoretype.create :name => "adjust_score", :award => 0, :description => "adjustments made by the administrator", :version => 1
    
    
    #Creating Ratingtypes
    Ratingtype.create :rating_type => "up", :rating_value => 1
    Ratingtype.create :rating_type => "down", :rating_value => -1
    Ratingtype.create :rating_type => "bad (spam/abuse)", :rating_value => -1
    Ratingtype.create :rating_type => "nuke", :rating_value => -1
                          

    #Create default subscription types for all conversations or items
    Subscription.create(:sub_type => "item", :sub_name => "all_conversations")
    Subscription.create(:sub_type => "item", :sub_name => "all")
    
    #Generate subscriptions for any pre-existing items
    Item.find(:all).each {|item| item.update_subscriptions }

    

end
