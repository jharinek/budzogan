class Task < ActiveRecord::Base
  STATES = [:new, :in_progress, :solved]

  belongs_to :exercise
  belongs_to :sentence, counter_cache: true
  belongs_to :user

  before_create :initialize_solution

  validates :exercise, presence: true

  scope :started, lambda { where.not(state: 0) }

  def initialize_solution
    teacher_solution = student_solution = "{\"cells\":[]}"
  end

  def initialize_state
    state = STATES.first
  end

  def self.create_and_assign(sentences, assignee, exercise)
    sentences.each do |sentence|
      Task.create(sentence: sentence, user: assignee, exercise: exercise)
    end
  end
end

