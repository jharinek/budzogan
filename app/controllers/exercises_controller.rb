class ExercisesController < ApplicationController
  def new
    @exercise = Exercise.new
    @exercise_types = ExerciseTemplate.pluck(:name, :id)
  end

  def create
    render nothing: true
  end
end