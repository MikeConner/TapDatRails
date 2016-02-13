class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.references :user
      t.string :name, :null => false
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.integer :zipcode
      t.string :website
      t.string :facebook
      t.string :twitter

      t.timestamps
    end
  end
end
