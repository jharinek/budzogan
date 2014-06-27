class Task < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :sentence

  has_many :task_assignments, dependent: :destroy
  has_many :students, class_name: :User, through: :task_assignments

  before_create :set_solution

  def set_solution
    this.student_solution = "{\"cells\":[]}"
  end
end
