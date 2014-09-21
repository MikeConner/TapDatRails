class AddDefaultParamsToUsers < ActiveRecord::Migration
  def up
    change_column :users, :satoshi_balance, :integer, :null => false, :default => 0
    change_column :users, :phone_secret_key, :string, :null => false
  end
  
  def down
    change_column :users, :satoshi_balance, :integer
    change_column :users, :phone_secret_key, :string
  end
end
