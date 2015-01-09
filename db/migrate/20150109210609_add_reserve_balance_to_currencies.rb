class AddReserveBalanceToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :reserve_balance, :integer, :null => false, :default => 0
  end
end
