class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :templates, class_name: :ExerciseTemplate, through: :taggings
end
