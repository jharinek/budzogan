class Exercise < ActiveRecord::Base
  STATUSES   = [:new, :setup, :sentences, :assignment, :active]
  LEVELS     = [:easy, :medium, :hard]
  STRATEGIES = [:one_to_one, :every_to_everyone, :custom]

  has_and_belongs_to_many :sentences

  belongs_to :template, class_name: :ExerciseTemplate
  belongs_to :workgroup

  has_many :element_assignments, as: :elementable, dependent: :destroy
  has_many :elements, through: :element_assignments

  has_many :tasks, dependent: :destroy

  with_options if: :active_or_setup? do |exercise|
    exercise.validates :description, format: { with: /[\s\w\<\>\?\.\,\:\;\'\"\{\}\(\)]*/ }, presence: true
    exercise.validates :template_id, numericality: true, presence: true
  end

  with_options if: :active_or_sentences? do |exercise|
    exercise.validates :sentence_length, numericality: { only_integer: true }, allow_blank: true
    exercise.validates :sentence_difficulty, inclusion: { in: LEVELS }, allow_blank: true
  end

  validates :distribution_strategy, presence: true, inclusion: { in: STRATEGIES }, if: :active_or_assignment?

  validates :status, inclusion: { in: STATUSES }, presence: true

  symbolize :status
  symbolize :sentence_difficulty
  symbolize :distribution_strategy

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
