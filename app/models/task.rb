class Task < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :sentence

  has_many :task_assignments, dependent: :destroy
  has_many :students, class_name: :User, through: :task_assignments

  before_create :initialize_solution

  def initialize_solution
    this.student_solution = "{\"cells\":[]}"
  end
end
