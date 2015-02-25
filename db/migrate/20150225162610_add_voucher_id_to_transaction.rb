class AddVoucherIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :voucher_id, :integer
  end
end
