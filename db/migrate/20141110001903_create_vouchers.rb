class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.references :currency
      t.references :balance
      t.string :uid, :null => false, :limit => 16 # Voucher::UID_LEN
      t.integer :amount, :null => false
      t.integer :status, :null => false, :default => 0 # Voucher::Active

      t.timestamps
    end
    
    add_index :vouchers, :uid, :unique => true
  end
end
