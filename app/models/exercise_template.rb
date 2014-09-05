class ExerciseTemplate < ActiveRecord::Base
  has_many :attribute_assingments, as: :attributable, dependent: :destroy
  has_many :attributes, through: :attribute_assignments
  has_many :exercises
end
