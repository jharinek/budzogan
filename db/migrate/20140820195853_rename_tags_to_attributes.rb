class RenameTagsToAttributes < ActiveRecord::Migration
  def change
    rename_table :taggings, :attribute_assignments
    rename_table :tags, :attributes
  end
end
