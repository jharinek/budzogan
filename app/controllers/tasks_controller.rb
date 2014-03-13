class TasksController < ApplicationController
  def solve
    # TODO (jharinek) Refactor according to sentence model
    @sentence = "Veta na rozbor".split
  end
end
