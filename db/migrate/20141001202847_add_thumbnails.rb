class AddThumbnails < ActiveRecord::Migration
  def change
    add_column :payloads, :payload_image, :string
    add_column :payloads, :payload_thumb, :string
    add_column :users, :profile_thumb, :string
  end
end
