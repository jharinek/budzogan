class ExerciseTemplate < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :exercises
end
