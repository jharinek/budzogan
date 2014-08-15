class Exercises::BuildController < ApplicationController
  include Wicked::Wizard

  steps :setup, :sentences, :assignment

  def show
    # @exercise = Exercise.find(params[:exercise_id])

    render_wizard
  end
end
