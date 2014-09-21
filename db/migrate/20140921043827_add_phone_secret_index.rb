class AddPhoneSecretIndex < ActiveRecord::Migration
  def up
    change_column :users, :phone_secret_key, :string, :null => false, :limit => 16
    add_index :users, :phone_secret_key, :unique => true
  end
  
  def down
    change_column :users, :phone_secret_key, :string
    remove_index :users, :phone_secret_key
  end
end
