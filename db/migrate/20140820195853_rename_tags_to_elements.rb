class RenameTagsToElements < ActiveRecord::Migration
  def change
    rename_table :taggings, :element_assignments
    rename_table :tags, :elements

    rename_column :element_assignments, :tag_id, :element_id
  end
end
e