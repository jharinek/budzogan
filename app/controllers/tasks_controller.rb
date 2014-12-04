class TasksController < ApplicationController

  def index
    @tasks = current_user.tasks.order(:created_at)
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(task_params)
  end

  def show
    @task = Task.find(params[:id])
  end

  def edit
    @task = Task.find(params[:id])
    @sentence = Task.find(params[:id]).sentence.content.split

    @used_words = []
    @used_words = @task.student_solution["cells"].map {|cell| cell["attrs"]["text"]["text"] if cell["type"] == "erd.EntityDeletable"} if @task.student_solution
    @used_words.compact!
    @used_words = @used_words.collect(&:split).flatten
  end

  def update
    @task = Task.find(params[:id])

    @task.student_solution = params[:graph].to_json || @task.student_solution

    # TODO weird task state representation
    @task.state = params[:state].to_i || 0

    @task.save!

    render nothing: true
  end

  private
  def empty?

  end
end
