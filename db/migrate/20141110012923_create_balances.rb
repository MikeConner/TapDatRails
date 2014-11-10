class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.references :user
      t.string :currency_name, :null => false
      t.integer :amount, :null => false, :default => 0
      t.datetime :expiration_date

      t.timestamps
    end
    
    add_index :balances, [:user_id, :currency_name], :unique => true
  end
end
