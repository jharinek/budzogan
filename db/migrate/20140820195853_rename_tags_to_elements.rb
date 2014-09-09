class RenameTagsToElements < ActiveRecord::Migration
  def change
    rename_table :taggings, :element_assignments
    rename_table :tags, :elements
  end
end
