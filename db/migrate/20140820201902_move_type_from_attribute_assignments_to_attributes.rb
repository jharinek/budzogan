class MoveTypeFromAttributeAssignmentsToAttributes < ActiveRecord::Migration
  def change
    remove_column :attribute_assignments, :type
    add_column :attributes, :category, :string, null: false, default: ''
  end
end
