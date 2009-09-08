class CreateSiteConfigs < ActiveRecord::Migration
  def self.up
    create_table :site_configs do |t|
      t.column :site_name, :string, :default => "Discussion Site", :null => false
      t.column :org_name, :string, :default => "Discussion Site", :null => false
      t.column :site_url, :string, :default => "127.0.0.1", :null => false
      t.column :org_url, :string, :default => "example.org", :null => false
      t.column :rcc_pub, :string
      t.column :rcc_priv, :string
      t.column :site_logo_url, :string, :default => "/images/lv-logo.png", :null => false
      t.column :org_logo_url, :string, :default => "/images/org-logo.png", :null => false
      t.column :m_server_addr, :string
      t.column :m_server_port, :integer
      t.column :m_server_domain, :string
      t.column :deleted, :integer, :default => 0, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :site_configs
  end
end
