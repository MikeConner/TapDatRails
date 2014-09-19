class AddPhoneFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone_secret_key, :string, :limit => 16
    add_column :users, :inbound_btc_address, :string
    add_column :users, :outbound_btc_address, :string
    add_column :users, :satoshi_balance, :integer
  end
end
