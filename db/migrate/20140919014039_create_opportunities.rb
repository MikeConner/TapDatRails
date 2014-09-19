class CreateOpportunities < ActiveRecord::Migration
  def change
    create_table :opportunities do |t|
      t.string :name
      t.string :email
      t.string :location

      t.timestamps
    end
  end
end
