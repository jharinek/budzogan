class AddPolymorphismToElementAssignments < ActiveRecord::Migration
  def change
    add_column :element_assignments, :elementable_type, :string, null: false, default: ''
    add_column :element_assignments, :elementable_id, :integer, null: false
  end
end
