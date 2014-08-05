class RemoveUnderscoreFromWorkGroupTableName < ActiveRecord::Migration
  def change
    rename_table  :work_groups, :workgroups
    rename_column :enrollments, :work_group_id, :workgroup_id
    rename_column :exercises,   :work_group_id, :workgroup_id
  end
end
