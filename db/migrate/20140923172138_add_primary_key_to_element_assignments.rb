class AddPrimaryKeyToElementAssignments < ActiveRecord::Migration
  def change
    add_index :element_assignments, [:element_id, :elementable_id], unique: true
  end
end
