class AddMaxAmountToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :max_amount, :integer, :null => false, :default => 500 # Currency::MAX_AMOUNT
  end
end
