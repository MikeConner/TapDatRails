class AddUniqueIndexToPayloads < ActiveRecord::Migration
  def change
    add_index :payloads, [:nfc_tag_id, :threshold], :unique => true
  end
end
