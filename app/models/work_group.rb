class WorkGroup < ActiveRecord::Base
  has_many :exercises
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments

  belongs_to :teacher, class_name: :User
  #
  #def teacher
  #  User.where(id: teacher_id).first
  #end
end
