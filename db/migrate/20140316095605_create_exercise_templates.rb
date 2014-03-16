class CreateExerciseTemplates < ActiveRecord::Migration
  def change
    create_table :exercise_templates do |t|
      t.string :text, null: false, default: ''

      t.timestamps
    end
  end
end
