class AddStatusToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :status, :string, null: false, default: ''
  end
end
