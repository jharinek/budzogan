class WorkgroupsController < ApplicationController
  def index
    @groups = Workgroup.where(teacher: current_user)
  end

  def new
    @students  = User.students_for_current_school current_user
    @students.order(grade: :asc)
    @workgroup = Workgroup.new
  end

  def create
    @workgroup = Workgroup.new(workgroup_params)

    if @workgroup.save
      flash[:notice] = "Skupina bola úspešne vytvorená"

      redirect_to workgroups_path
    else
      flash_error_messages_for @workgroup

      @students  = User.students_for_current_school current_user
      @students.order(grade: :asc)
      render :new
    end
  end

  def update
    @workgroup = Workgroup.find(params[:id])

    @workgroup.update(workgroup_params)

    redirect_to workgroup_path(@workgroup.id)
  end

  def show
    @workgroup = Workgroup.find(params[:id])
    @students  = @workgroup.students
  end

  def edit
    @workgroup = Workgroup.find(params[:id])
    @students  = @workgroup.students
  end

  private
  def workgroup_params
    params.require(:workgroup).permit(:name).merge(teacher: current_user, students: User.find(student_ids))
  end

  def student_ids
    student_ids = []
    (params.keys.select { |key| key.match /student_/ }).each { |key| student_ids.push(key.gsub(/student_/, '').to_i) }
    student_ids
  end
end