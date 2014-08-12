class RenameTextToNameInExerciseTempaltes < ActiveRecord::Migration
  def change
    rename_column :exercise_templates, :text, :name
  end
end
