class AddSlugToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :slug, :string
    
    add_index :currencies, :slug, :unique => true
  end
end
