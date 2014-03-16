class Task < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :sentence

  has_many :students, class_name: :User, through: :task_assignments

end
