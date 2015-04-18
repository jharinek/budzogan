class FixElapsedTime < ActiveRecord::Migration
  def change
    Task.find_each do |task|
      task.elapsed_time -= 10 if task.elapsed_time > 0
      task.save!
    end
  end
end
