class AddContentTypeToPayload < ActiveRecord::Migration
  def change
    add_column :payloads, :content_type, :string, :null => false, :default => 'image', :limit => 16
  end
end
