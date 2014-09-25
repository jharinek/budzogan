class Exercises::BuildController < ApplicationController
  include Wicked::Wizard

  steps :setup, :sentences, :assignment

  def show
    @exercise = Exercise.find(params[:exercise_id])
    render_wizard
  end

  def update
    @exercise = Exercise.find(params[:exercise_id])
    params[:exercise][:status] = step.to_sym
    params[:exercise][:status] = :active if step == steps.last

    @exercise.update_attributes(exercise_params)
    assign_elements if step == :setup

    render_wizard @exercise
  end

  private
  def assign_elements
    elements = Element.find(params[:exercise][:element_ids].reject(&:empty?))
    @exercise.elements.each { |e| elements.delete e }
    @exercise.elements << elements
  end

  def exercise_params
    date_params = params.require(:exercise)
    params.require(:exercise).permit(:template_id, :description, :sentence_length, :sentence_difficulty, :sentence_source, :status).merge(
      start_time: DateTime.new(date_params["start_time(1i)"].to_i, date_params["start_time(2i)"].to_i, date_params["start_time(3i)"].to_i,
                               date_params["start_time(4i)"].to_i, date_params["start_time(5i)"].to_i),
      end_time:   DateTime.new(date_params["end_time(1i)"].to_i, date_params["end_time(2i)"].to_i, date_params["end_time(3i)"].to_i,
                               date_params["end_time(4i)"].to_i, date_params["end_time(5i)"].to_i)
    )
  end
end
