class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :user_id, :email, :code
      t.boolean :used
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
