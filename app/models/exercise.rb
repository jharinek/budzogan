class Exercise < ActiveRecord::Base
  STATUSES = [:new, :setup, :sentences, :assignment, :active]
  LEVELS   = [:easy, :medium, :hard]

  belongs_to :template, class_name: :ExerciseTemplate
  belongs_to :workgroup

  has_many :element_assignments, as: :elementable, dependent: :destroy
  has_many :elements, through: :element_assignments

  has_many :tasks, dependent: :destroy

  validates :description, format: { with: // }, presence: true, if: :active_or_setup?

  with_options if: :active_or_sentences? do |exercise|
    exercise.validates :sentence_length, numericality: { only_integer: true, greater_than: 0 }, presence: true
    exercise.validates :sentence_difficulty, inclusion: { in: LEVELS }, presence: true
  end

  validates :status, inclusion: { in: STATUSES }, presence: true

  def active?
    status == :active
  end

  def active_or_setup?
    status.eql?(:setup) || active?
  end

  def active_or_sentences?
    status.eql?(:sentences) || active?
  end

  def active_or_assignment?
    status.eql?(:assignment) || active?
  end
end
