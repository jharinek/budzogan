class WorkGroup < ActiveRecord::Base
  has_many :exercises
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments
end
