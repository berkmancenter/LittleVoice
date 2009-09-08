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

ActiveRecord::Schema.define(:version => 20090903145259) do

  create_table "content_versions", :force => true do |t|
    t.integer  "content_id"
    t.text     "body"
    t.string   "controller"
    t.string   "action"
    t.string   "name"
    t.string   "location"
    t.integer  "version"
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
    t.integer  "version"
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
    t.integer  "item_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "itemtype_id"
    t.integer  "item_root_id"
    t.integer  "parent_id"
    t.string   "item_title"
    t.text     "itemtext"
    t.boolean  "item_active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lft"
    t.integer  "rgt"
  end

  create_table "itemtypes", :force => true do |t|
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratingactions", :force => true do |t|
    t.integer  "item_id"
    t.boolean  "rating",        :default => false
    t.integer  "ratingtype_id", :default => 0,     :null => false
    t.integer  "user_id",       :default => 0,     :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "user_level"
  end

  create_table "ratingitemtotals", :force => true do |t|
    t.integer  "item_id",      :default => 0, :null => false
    t.integer  "rating_total", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "parent_id"
  end

  create_table "ratingtypes", :force => true do |t|
    t.string   "rating_type",                 :null => false
    t.integer  "rating_value", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "reputations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "rawscore"
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
    t.integer  "user_id"
    t.integer  "item_id"
    t.integer  "scoretype_id"
    t.integer  "rawscore"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "award"
  end

  create_table "scoretypes", :force => true do |t|
    t.string   "name",        :limit => 20
    t.integer  "award"
    t.integer  "version"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "namespace",  :default => "LV", :null => false
    t.string   "key",                          :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["key", "namespace"], :name => "index_settings_on_key_and_namespace", :unique => true
  add_index "settings", ["namespace", "key"], :name => "index_settings_on_namespace_and_key", :unique => true

  create_table "site_configs", :force => true do |t|
    t.string   "site_name",       :default => "Discussion Site",      :null => false
    t.string   "org_name",        :default => "Discussion Site",      :null => false
    t.string   "site_url",        :default => "127.0.0.1",            :null => false
    t.string   "org_url",         :default => "example.org",          :null => false
    t.string   "rcc_pub"
    t.string   "rcc_priv"
    t.string   "site_logo_url",   :default => "/images/lv-logo.png",  :null => false
    t.string   "org_logo_url",    :default => "/images/org-logo.png", :null => false
    t.string   "m_server_addr"
    t.integer  "m_server_port"
    t.string   "m_server_domain"
    t.integer  "deleted",         :default => 0,                      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.string  "sub_type"
    t.string  "sub_name"
    t.integer "sub_type_id"
  end

  create_table "subscriptions_users", :id => false, :force => true do |t|
    t.integer "subscription_id"
    t.integer "user_id"
  end

  create_table "survey_responses", :force => true do |t|
    t.string "survey_name"
    t.binary "responses"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
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
    t.string   "identity_url"
    t.integer  "fb_user_id",                :limit => 8
    t.string   "email_hash"
  end

end
