class CreatePayloads < ActiveRecord::Migration
  def change
    create_table :payloads do |t|
      t.references :nfc_tag, :null => false
      t.string :uri
      t.text :content
      t.integer :threshold, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :payloads, :nfc_tag_id
  end
end
