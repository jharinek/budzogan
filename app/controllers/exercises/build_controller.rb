class Exercises::BuildController < ApplicationController
  include Wicked::Wizard

  steps :setup, :sentences, :assignment

  def show
    @exercise = Exercise.find(params[:exercise_id])
    render_wizard
  end

  def update
    @exercise = Exercise.find(params[:exercise_id])
    @exercise.update(exercise_params)

    render_wizard @exercise
  end

  private
  def exercise_params
    params.require(:exercise).permit(:description, :sentence_length, :sentence_difficulty, :sentence_source, :state)
  end
end
