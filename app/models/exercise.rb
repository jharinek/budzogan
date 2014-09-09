class Exercise < ActiveRecord::Base
  belongs_to :template, class_name: :ExerciseTemplate
  belongs_to :workgroup

  has_many :element_assignments, as: :elementable, dependent: :destroy
  has_many :elements, through: :element_assignments

  has_many :tasks, dependent: :destroy

  def active?
    state == 'active'
  end
end
