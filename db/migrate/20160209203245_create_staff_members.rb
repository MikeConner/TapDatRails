class CreateStaffMembers < ActiveRecord::Migration
  def change
    create_table :staff_members do |t|
      t.references :venue
      t.references :user
      t.string :display_name, :null => false
      t.string :first_name
      t.string :last_name
      t.integer :age
      t.string :body_type
      t.string :ethnicity
      t.string :sexuality
      t.string :eye_color
      t.string :hair_color
      t.string :status
      t.string :type

      t.timestamps
    end
  end
end
