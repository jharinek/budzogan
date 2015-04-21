class AddSolutionToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :solution, :text
  end
end
