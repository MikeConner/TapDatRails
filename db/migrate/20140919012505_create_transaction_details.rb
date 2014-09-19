class CreateTransactionDetails < ActiveRecord::Migration
  def change
    create_table :transaction_details do |t|
      t.references :transaction
      t.integer :subject_id, :null => false
      t.integer :target_id, :null => false
      t.integer :credit_satoshi
      t.integer :debit_satoshi
      t.decimal :conversion_rate, :null => false

      t.timestamps
    end
    
    add_index :transaction_details, :subject_id
    add_index :transaction_details, :target_id
  end
end
