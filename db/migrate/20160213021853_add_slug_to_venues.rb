class AddSlugToVenues < ActiveRecord::Migration
  def up
    create_table :activity_types do |t|
      t.string :name, :null => false

      t.timestamps
    end

    ActivityType.create(:name => 'Tipping')
    ActivityType.create(:name => 'Scavenger Hunt')
    ActivityType.create(:name => 'Charity')
    
    add_column :venues, :slug, :string
    add_column :venues, :activity_type, :integer, :null => false, :default => 0
    add_column :venues, :main_image, :string
    add_column :venues, :main_image_processing, :boolean
    add_column :venues, :activity_type_id, :integer, :null => false, :default => 1
    remove_column :venues, :activity_type
  end
  
  def down
    drop_table :activity_types
    
    remove_column :venues, :slug
    remove_column :venues, :activity_type
    remove_column :venues, :main_image
    remove_column :venues, :main_image_processing
    remove_column :venues, :activity_type_id
    add_column :activity_type, :integer
 end
end
