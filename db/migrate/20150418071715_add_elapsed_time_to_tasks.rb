class AddElapsedTimeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :elapsed_time, :integer, default: 0
  end
end
