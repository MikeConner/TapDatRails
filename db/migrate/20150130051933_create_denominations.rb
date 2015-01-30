class CreateDenominations < ActiveRecord::Migration
  def up
    create_table :denominations do |t|
      t.references :currency
      t.integer :value
      t.string :image

      t.timestamps
    end
    
    remove_column :currencies, :denominations
  end
  
  def down
    drop_table :denominations
    
    add_column :currencies, :denominations, :string
  end
end
