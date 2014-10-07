class AddQrCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :inbound_btc_qrcode, :string
  end
end
