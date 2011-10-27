class AddUsersFb < ActiveRecord::Migration
  def self.up
    add_column "#{Security.connection.instance_eval{@config[:database]}}.users", :fb_user_id, :integer
    add_column "#{Security.connection.instance_eval{@config[:database]}}.users", :email_hash, :string
    #if mysql
    execute("alter table #{Security.connection.instance_eval{@config[:database]}}.users modify fb_user_id bigint")
  end

  def self.down
    remove_column "#{Security.connection.instance_eval{@config[:database]}}.users", :fb_user_id
    remove_column "#{Security.connection.instance_eval{@config[:database]}}.users", :email_hash
  end
end
