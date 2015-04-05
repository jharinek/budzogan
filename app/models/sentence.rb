class Sentence < ActiveRecord::Base
  has_and_belongs_to_many :exercises

  has_many :tasks

  scope :needed, lambda{ where('tasks_count < 6') }

  scope :long,   lambda{ |count| needed.where('length > 10').limit(count) }
  scope :medium, lambda{ |count| needed.where('length > 5').where('length < 11').limit(count) }
  scope :short,  lambda{ |count| needed.where('length < 6').limit(count) }

  before_create :compute_length

  def self.get_bulk(size)
    remaining = size
    bulk_size = size/3

    sentences = self.long(bulk_size)
    remaining -= bulk_size
    self.medium(bulk_size).each { |s| sentences << s }
    remaining -= bulk_size
    self.short(remaining).each { |s| sentences << s }

    sentences
  end

  private
  def compute_length
    length = content.split(' ').count
  end
end
