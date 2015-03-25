class AdjustUserFields < ActiveRecord::Migration
  def up
    remove_column :users, :profile_thumb
    add_column :users, :slug, :string
    add_column :users, :profile_image_processing, :boolean
    add_column :users, :inbound_btc_qrcode_processing, :boolean
    
    add_index :users, :slug, :unique => true
  end
  
  def down
    add_column :users, :profile_thumb, :string
    remove_column :users, :slug
    remove_column :users, :profile_image_processing
    remove_column :users, :inbound_btc_qrcode_processing
  end
end
