class AddStateToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :state, :string, null: false, default: ''
  end
end
