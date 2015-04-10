class CreateBalanceCaches < ActiveRecord::Migration
  def change
    create_table :balance_caches do |t|
      t.string :btc_address, :null => false, :limit => 36
      t.integer :satoshi, :null => false, :limit => 8

      t.timestamps
    end
    
    add_index :balance_caches, :btc_address, :unique => true
  end
end
