class ExercisesController < ApplicationController
  def new
    @exercise = Exercise.new
    @exercise_types = ExerciseTemplate.pluck(:id, :name)
  end

  def create

  end
end