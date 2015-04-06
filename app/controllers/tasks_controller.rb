class TasksController < ApplicationController

  def index
    @tasks = current_user.tasks.order(created_at: :desc)
    # @tasks.page(params[:page]).per(10)
  end

  def edit
    @task = Task.find(params[:id])
    @sentence = Task.find(params[:id]).sentence.content.split

    @used_words = []
    @used_words = @task.student_solution["cells"].map {|cell| cell["attrs"]["text"]["text"] if cell["type"] == "nlp.Element"} if @task.student_solution
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

  def generate
    @sentences = Sentence.get_bulk(10)

    # TODO get reasonable exercise value
    Task.create_and_assign(@sentences, current_user, Exercise.first)

    redirect_to tasks_path
  end

  private

  def empty?

  end
end
