class Task < ActiveRecord::Base
  STATES = [:new, :in_progress, :solved]

  belongs_to :exercise
  belongs_to :sentence

  has_many :task_assignments, dependent: :destroy
  has_many :students, class_name: :User, through: :task_assignments

  before_create :initialize_solution

  def initialize_solution
    student_solution = "{\"cells\":[]}"
  end

  def initialize_state
    state = STATES.first
  end
end
