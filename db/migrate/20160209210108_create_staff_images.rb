class CreateStaffImages < ActiveRecord::Migration
  def change
    create_table :staff_images do |t|
      t.references :staff_member
      t.string :caption
      t.string :profile_image
      t.boolean :profile_image_processing

      t.timestamps
    end
  end
end
