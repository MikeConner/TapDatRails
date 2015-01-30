class AddSymbolToCurrency < ActiveRecord::Migration
  def change
    add_column :currencies, :symbol, :char
  end
end
