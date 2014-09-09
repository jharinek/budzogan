class ExerciseTemplate < ActiveRecord::Base
  has_many :element_assignments, as: :elementable, dependent: :destroy
  has_many :elements, through: :element_assignments
  has_many :exercises
end
