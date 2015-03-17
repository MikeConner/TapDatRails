class AddDescriptionToPayloads < ActiveRecord::Migration
  def change
    add_column :payloads, :description, :string
  end
end
