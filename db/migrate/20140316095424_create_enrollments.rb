class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.integer :group_id
      t.integer :student_id

      t.timestamps
    end

    add_index :enrollments, :group_id
    add_index :enrollments, :student_id

  end
end
