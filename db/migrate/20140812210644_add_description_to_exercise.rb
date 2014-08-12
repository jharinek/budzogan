class AddDescriptionToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :description, :string, null: false, default: ''
  end
end
