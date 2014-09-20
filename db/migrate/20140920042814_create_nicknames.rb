class CreateNicknames < ActiveRecord::Migration
  def change
    create_table :nicknames do |t|
      t.integer :column, :null => false
      t.string :word, :null => false

      t.timestamps
    end
    
    add_index :nicknames, :word, :unique => true
  end
end
