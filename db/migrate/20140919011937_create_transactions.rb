class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user
      t.references :nfc_tag
      t.references :payload
      t.integer :dest_id
      t.integer :satoshi_amount
      t.integer :dollar_amount
      t.string :comment

      t.timestamps
    end
    
    add_index :transactions, :user_id
    add_index :transactions, :nfc_tag_id
    add_index :transactions, :payload_id
  end
end
