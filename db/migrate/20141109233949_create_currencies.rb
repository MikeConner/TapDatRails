class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.references :user
      t.string :name, :null => false, :limit => 24 # Currency::NAME_LEN
      t.string :icon
      t.string :denominations
      t.integer :expiration_days
      t.integer :status, :null => false, :default => 0 # Currency::Active
      
      t.timestamps
    end
    
    add_index :currencies, :name, :unique => true
  end
end
