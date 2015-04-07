class UpdateUsers < ActiveRecord::Migration
  def change
    change_column :users, :email, :string, null: true
    remove_column :users, :organization_id

    add_column :users, :organization, :string, null: false, default: ''
  end
end
