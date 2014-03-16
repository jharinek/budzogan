class CreateTaskAssignments < ActiveRecord::Migration
  def change
    create_table :task_assignments do |t|
      t.integer :user_id
      t.integer :task_id

      t.timestamps
    end

    add_index :task_assignments, :user_id
    add_index :task_assignments, :task_id
  end
end
