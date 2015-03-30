class Workgroup < ActiveRecord::Base
  has_many :exercises
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments

  belongs_to :teacher, class_name: :User
  belongs_to :organization

  validates :name, format: { with: /\A[\w.\-:\# ]*\z/ }, presence: true

  scope :for_current_school, lambda{ |teacher| where(organization: teacher.organization) }
end
