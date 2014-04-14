class Enrollment < ActiveRecord::Base
  belongs_to :student, class_name: :User
  belongs_to :work_group, class_name: :WorkGroup
end