class CreateNfcTags < ActiveRecord::Migration
  def change
    create_table :nfc_tags do |t|
      t.references :user
      t.string :name
      t.string :tag_id, :null => false
      t.integer :lifetime_balance, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :nfc_tags, :user_id
    add_index :nfc_tags, :tag_id, :unique => true
  end
end
