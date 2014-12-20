class Task < ActiveRecord::Base
  STATES = [:new, :in_progress, :solved]

  belongs_to :exercise
  belongs_to :sentence
  belongs_to :student, class_name: :User

  # has_many :task_assignments, dependent: :destroy
  # has_many :students, class_name: :User, through: :task_assignments

  before_create :initialize_solution

  scope :started, lambda { where.not(state: 0) }

  def initialize_solution
    teacher_solution = student_solution = "{\"cells\":[]}"
  end

  def initialize_state
    state = STATES.first
  end
end

