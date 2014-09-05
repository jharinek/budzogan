class Exercise < ActiveRecord::Base
  belongs_to :template, class_name: :ExerciseTemplate
  belongs_to :workgroup

  has_many :attribute_assignments, as: :attributable, dependent: :destroy
  has_many :attributes, through: :attribute_assignments

  has_many :tasks, dependent: :destroy

  def active?
    state == 'active'
  end
end
