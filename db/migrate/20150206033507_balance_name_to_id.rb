class BalanceNameToId < ActiveRecord::Migration
  def up
    remove_column :balances, :currency_name
    add_column :balances, :currency_id, :integer
  end
  
  def down
    add_column :balances, :currency_name, :string
    remove_column :balances, :currency_id    
  end
end
