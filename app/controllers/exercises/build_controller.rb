class Exercises::BuildController < ApplicationController
  include Wicked::Wizard

  steps :setup, :sentences, :assignment

  def show
    @exercise = Exercise.find(params[:exercise_id])
    render_wizard
  end

  def update
    @exercise = Exercise.find(params[:exercise_id])
    params[:exercise][:status] = step.to_s
    params[:exercise][:status] = :active if step == steps.last
    @exercise.update_attributes(exercise_params)

    render_wizard @exercise
  end

  private
  def exercise_params
    params.require(:exercise).permit(:description, :sentence_length, :sentence_difficulty, :sentence_source, :status)
  end
end
