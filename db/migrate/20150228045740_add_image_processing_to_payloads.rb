class AddImageProcessingToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :payload_image_processing, :boolean
    add_column :payloads, :payload_thumb_processing, :boolean
  end
end
