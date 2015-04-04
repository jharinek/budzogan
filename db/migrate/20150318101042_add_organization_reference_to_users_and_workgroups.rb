class AddOrganizationReferenceToUsersAndWorkgroups < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer
    add_column :workgroups, :organization_id, :integer
  end
end
