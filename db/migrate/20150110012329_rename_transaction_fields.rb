class RenameTransactionFields < ActiveRecord::Migration
  def change
    rename_column :transactions, :satoshi_amount, :amount
    rename_column :transaction_details, :credit_satoshi, :credit
    rename_column :transaction_details, :debit_satoshi, :debit
  end
end
