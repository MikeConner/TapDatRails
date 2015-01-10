class AddIconProcessingToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :icon_processing, :boolean
  end
end
