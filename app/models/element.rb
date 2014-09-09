class Element < ActiveRecord::Base
  has_many :element_assignments, dependent: :destroy
  has_many :templates, class_name: :ExerciseTemplate, through: :element_assignments
end
