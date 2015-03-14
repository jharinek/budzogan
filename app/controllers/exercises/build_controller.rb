class Exercises::BuildController < ApplicationController
  include Wicked::Wizard

  steps :setup, :sentences, :assignment

  def show
    @exercise     = Exercise.find(params[:exercise_id])
    @workgroups   = Workgroup.all
    @strategies   = { one_to_one:        'Každý študent jedna veta',
                      every_to_everyone: 'Každý študent všetky vety' }
    @difficulties = { easy:   'ľahká',
                      medium: 'stredná',
                      hard:   'ťažká' }
    @sources      = { sme:  'sme.sk',
                      juls: 'Národný korpus' }

    render_wizard
  end

  def update
    @exercise = Exercise.find(params[:exercise_id])
    params[:exercise][:status] = step.to_sym
    params[:exercise][:status] = :active if step == steps.last

    @exercise.update_attributes(step.to_sym == :assignment ? exercise_params.merge(inject_time_boundaries) : exercise_params)
    assign_elements if step == :setup

    render_wizard @exercise
  end

  private
  def assign_elements
    elements = Element.find(params[:exercise][:element_ids].reject(&:empty?))
    @exercise.elements.each { |e| elements.delete e }
    @exercise.elements << elements
  end

  def create_timestamp(year, month, day, hour, minute)
    return DateTime.new(year, month, day, hour, minute) unless year.zero?
    ''
  end

  def inject_time_boundaries
    date_params = params.require(:exercise)
    { start_time: create_timestamp(date_params["start_time(1i)"].to_i, date_params["start_time(2i)"].to_i, date_params["start_time(3i)"].to_i,
                                   date_params["start_time(4i)"].to_i, date_params["start_time(5i)"].to_i),
      end_time: create_timestamp(date_params["end_time(1i)"].to_i, date_params["end_time(2i)"].to_i, date_params["end_time(3i)"].to_i,
                                 date_params["end_time(4i)"].to_i, date_params["end_time(5i)"].to_i)
    }
  end

  def exercise_params
    params.require(:exercise).permit(:template_id, :description, :sentence_length, :sentence_difficulty,
                                     :sentence_source, :status, :distribution_strategy).merge(workgroup: Workgroup.find_by(id: params[:exercise][:workgroup]))
  end
end
