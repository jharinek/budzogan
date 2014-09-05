class Attribute < ActiveRecord::Base
  has_many :attribute_assignments, dependent: :destroy
  has_many :templates, class_name: :ExerciseTemplate, through: :exercise_assignments
end
