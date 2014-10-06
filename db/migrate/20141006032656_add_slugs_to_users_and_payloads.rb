class AddSlugsToUsersAndPayloads < ActiveRecord::Migration
  def change
    add_column :transactions, :slug, :string
    add_column :payloads, :slug, :string
    
    add_index :transactions, :slug, :unique => true
    add_index :payloads, :slug, :unique => true
  end
end
