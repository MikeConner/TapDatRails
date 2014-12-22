class AddRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :role, :integer, :null => false, :default => 0 # Regular user, no special role (roles are bit-masked)
  end
end
