 class CreateUsers < ActiveRecord::Migration
   def self.up
     create_table "users", :force => true do |t|
       t.column :login,                     :string
       t.column :email,                     :string
       t.column :crypted_password,          :string, :limit => 40
       t.column :salt,                      :string, :limit => 40
       t.column :created_at,                :datetime
       t.column :updated_at,                :datetime
       t.column :remember_token,            :string
       t.column :remember_token_expires_at, :datetime
       t.column :activation_code, :string, :limit => 40
       t.column :activated_at, :datetime
       t.column :password_reset_code, :string, :limit => 40
       t.column :enabled, :boolean, :default => true      
     end
     
     #password: "mypass"
     User.create :login => 'anonymous', :crypted_password => "96996855a9d278d0bed0a7509c7f0b1d282943a0", :salt =>"22d879bd5a41dac8d5a9295816c469872728cdbf", :created_at => Time.new, :updated_at => Time.new, :activated_at => Time.new, :enabled => 1

   end
  
   def self.down
     drop_table "users"
   end
 end

