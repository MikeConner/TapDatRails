class ChangeVoucherOwnership < ActiveRecord::Migration
  def change
    rename_column :vouchers, :balance_id, :user_id
  end
end
