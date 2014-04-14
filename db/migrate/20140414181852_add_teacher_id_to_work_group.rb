class AddTeacherIdToWorkGroup < ActiveRecord::Migration
  def change
    add_column :work_groups, :teacher_id, :integer, null: false, default: 0

    add_index :work_groups, :teacher_id
  end
end
