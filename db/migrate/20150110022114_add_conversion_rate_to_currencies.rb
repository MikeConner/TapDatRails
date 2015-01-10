class AddConversionRateToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :amount_per_dollar, :integer, :null => false, :default => 100
  end
end
