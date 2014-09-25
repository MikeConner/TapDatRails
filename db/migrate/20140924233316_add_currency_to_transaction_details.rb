class AddCurrencyToTransactionDetails < ActiveRecord::Migration
  def change
    add_column :transaction_details, :currency, :string, :limit => 16, :null => false, :default => 'USD'
  end
end
