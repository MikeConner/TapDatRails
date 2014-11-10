class AddCurrencyToNfcTag < ActiveRecord::Migration
  def change
    add_column :nfc_tags, :currency_id, :integer
  end
end
