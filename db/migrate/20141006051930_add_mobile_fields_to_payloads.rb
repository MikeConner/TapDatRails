class AddMobileFieldsToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :mobile_payload_image_url, :string
    add_column :payloads, :mobile_payload_thumb_url, :string
  end
end
