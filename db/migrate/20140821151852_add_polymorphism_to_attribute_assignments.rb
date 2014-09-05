class AddPolymorphismToAttributeAssignments < ActiveRecord::Migration
  def change
    add_column :attribute_assignments, :attributable_type, :string, null: false, default: ''
    add_column :attribute_assignments, :attributable_id, :integer, null: false
  end
end
