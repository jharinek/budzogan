class TasksController < ApplicationController

  def index
    @tasks = current_user.tasks
  end

  def new

  end

  def create

  end

  def show

  end

  def edit
    @sentence = Task.find_by(id: params[:id]).sentence.content.split
  end
end
