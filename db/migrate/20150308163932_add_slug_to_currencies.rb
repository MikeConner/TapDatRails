class AddSlugToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :slug, :string
  end
end
