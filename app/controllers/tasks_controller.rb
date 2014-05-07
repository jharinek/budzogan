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
    @sentence = Task.find_by(id: params[:id]).sentence.content.split
  end

  def update
    @task = Task.find(params[:id])
    solution = params[:graph].to_json || @task.solution
    @task.student_solution = solution

    @task.save!

    render nothing: true
  end
end
