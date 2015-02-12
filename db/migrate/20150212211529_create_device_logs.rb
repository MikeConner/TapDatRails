class CreateDeviceLogs < ActiveRecord::Migration
  def change
    create_table :device_logs do |t|
      t.string :user, :null => false, :limit => 16
      t.string :os, :null => false, :limit => 32
      t.string :hardware, :null => false, :limit => 48
      t.string :message, :null => false
      t.text :details

      t.timestamps
    end
    
    add_index :device_logs, :user
    add_index :device_logs, :os
    add_index :device_logs, :hardware
  end
end
