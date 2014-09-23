class AddStartAndEndDateTimestampsToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :start_time, :datetime, null: true
    add_column :exercises, :end_time, :datetime, null: true

    Exercise.all.each do |exercise|
      exercise.start_time = Time.now
      exercise.end_time   = Time.now + 1.day

      exercise.save!
    end
  end
end
