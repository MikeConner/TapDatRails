class RemovePayloadThumb < ActiveRecord::Migration
  def up
    remove_column :payloads, :payload_thumb
    remove_column :payloads, :payload_thumb_processing
  end
  
  def down
    add_column :payloads, :payload_thumb, :string
    add_column :payloads, :payload_thumb_processing, :boolean
  end
end
