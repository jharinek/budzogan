class TasksController < ApplicationController

  def index
    #require 'pry'; binding.pry
    @tasks = current_user.tasks
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
  end

  def show

  end

  def edit
    @sentence = Task.find_by(id: params[:id]).sentence.content.split
  end
end
