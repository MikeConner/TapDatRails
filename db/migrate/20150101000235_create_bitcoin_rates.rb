class CreateBitcoinRates < ActiveRecord::Migration
  def change
    create_table :bitcoin_rates do |t|
      t.float :rate

      t.timestamps
    end
  end
end
