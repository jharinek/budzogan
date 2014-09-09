class Element < ActiveRecord::Base
  has_many :element_assignments, dependent: :destroy

  with_options through: :element_assignments, source: :elementable do |element|
    element.has_many :templates, class_name: :ExerciseTemplate, source_type: 'ExerciseTemplate'
    element.has_many :exercises, source_type: 'Exercise'
  end
end
