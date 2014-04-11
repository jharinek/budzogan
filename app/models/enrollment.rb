class Enrollment < ActiveRecord::Base
  belongs_to :student, class_name: :User
  belongs_to :group, class_name: :WorkGroup
end