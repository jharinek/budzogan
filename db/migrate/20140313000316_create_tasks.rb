class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :sentence_id, null: false
      t.integer :exercise_id, null: false

      t.json :teacher_solution
      t.json :student_solution

      t.timestamps
    end
  end
end
