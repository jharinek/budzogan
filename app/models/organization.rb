class Organization < ActiveRecord::Base
  CATEGORIES = [:elementary_school, :high_school]

  has_many :users
  has_many :workgroups

  # TODO add format validation regexs
  validates :name, allow_blank: false, presence: true, uniqueness: { case_sensitive: false }
  validates :address, presence: true, allow_blank: true
  validates :category, presence: true

  symbolize :category, in: CATEGORIES
end