class AddExpirationDateToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :expiration_date, :date
  end
end
