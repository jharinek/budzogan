class MoveTypeFromElementAssignmentsToElements < ActiveRecord::Migration
  def change
    remove_column :element_assignments, :type, :string
    add_column :elements, :category, :string, null: false, default: ''
  end
end
