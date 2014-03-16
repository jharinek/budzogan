class Tags < ActiveRecord::Base
  has_many :templates, class_name: :ExerciseTemplate, through: :taggings
end
