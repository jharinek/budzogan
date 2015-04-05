class Sentence < ActiveRecord::Base
  has_and_belongs_to_many :exercises

  has_many :tasks

  scope :needed, lambda{ where(tasks.count < 6) }

  scope :long,   lambda{ |count| needed.where('length > 15').limit(count) }
  scope :medium, lambda{ |count| needed.where('length > 5').limit(count) }
  scope :short,  lambda{ |count| needed.where('length < 6').limit(count) }

  before_create :compute_length

  def self.get_bulk(size)
    self.limit(size)
  end

  private
  def compute_length
    length = content.split(' ').count
  end
end
