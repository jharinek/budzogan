class TasksController < ApplicationController

  def index
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
    @task = Task.find(params[:id])
    @sentence = Task.find(params[:id]).sentence.content.split
  end

  def update
    @task = Task.find(params[:id])

    @task.student_solution = params[:graph].to_json || @task.student_solution

    @task.save!

    render nothing: true
  end
end
