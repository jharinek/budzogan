class Exercise < ActiveRecord::Base
  belongs_to :template, class_name: :ExerciseTemplate
  belongs_to :workgroup

  has_many   :tasks, dependent: :destroy
end
