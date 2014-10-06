class AddMobileImageFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_profile_image_url, :string
    add_column :users, :mobile_profile_thumb_url, :string
  end
end
