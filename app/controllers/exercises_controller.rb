class ExercisesController < ApplicationController
  def create
    @exercise = Exercise.new(status: :new)

    if @exercise.save
      redirect_to exercise_build_path exercise_id: @exercise.id, id: :setup
    else
      redirect_to root_path
      flash_error_messages_for @exercise
    end
  end

  private
  def exercise_params
    params.require(:exercise).permit(:description, :sentence_length, :sentence_difficulty, :sentence_source, :state)
  end
end