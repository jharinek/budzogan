class WorkGroupsController < ApplicationController
  def index

  end

  def new
    @students = User.find_by(role: :student)
    @work_group    = WorkGroup.new
  end

  def create
    @work_group = WorkGroup.new(work_group_params)
  end

  def show
    @groups = WorkGroup.find_by(teacher: current_user)
  end
end