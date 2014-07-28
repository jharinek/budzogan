class WorkGroupsController < ApplicationController
  def index
    @groups = WorkGroup.where(teacher: current_user)
  end

  def new
    # TODO only students for actual school
    @students = User.where(role: :student)
    @work_group    = WorkGroup.new
  end

  def create
    @workgroup = WorkGroup.new(work_group_params)

    if @workgroup.save
      student_id_params.each do |id|
        Enrollment.create(student_id: id, work_group_id: @workgroup.id)
      end

      flash[:notice] = "Skupina bola úspešne vytvorená"
    else
      flash_error_messages_for @workgroup
    end

    redirect_to work_groups_path
  end

  def show
    @group = WorkGroup.find(params[:id])
  end

  def edit
    @workgroup = WorkGroup.find(params[:id])
    @students  = @workgroup.students
  end

  private
  def work_group_params
    params.require(:work_group).permit(:name).merge(teacher: current_user)
  end

  def student_id_params
    student_ids = []
    (params.keys.select { |key| key.match /student_/ }).each { |key| student_ids.push(key.gsub(/student_/, '').to_i) }
    student_ids
  end
end