class WorkGroup < ActiveRecord::Base
  has_many :exercises
  has_many :users, through: :enrollments
end
