class Sentence < ActiveRecord::Base
  has_and_belongs_to_many :exercises

  has_many :tasks

  scope :needed, lambda{ |ids_list| where('tasks_count < 6').where('id not in (?)', ids_list) }

  scope :long,   lambda{ |count, user| needed(invalid_ids_for(user)).where('length > 10').limit(count) }
  scope :medium, lambda{ |count, user| needed(invalid_ids_for(user)).where('length > 5').where('length < 11').limit(count) }
  scope :short,  lambda{ |count, user| needed(invalid_ids_for(user)).where('length < 6').limit(count) }

  before_create :compute_length

  def self.get_bulk(size, assignee)
    remaining = size
    bulk_size = size/3

    sentences = self.long(bulk_size, assignee)
    remaining -= bulk_size
    self.medium(bulk_size, assignee).each { |s| sentences << s }
    remaining -= bulk_size
    self.short(remaining, assignee).each { |s| sentences << s }

    sentences
  end

  private
  def compute_length
    length = content.split(' ').count
  end

  def self.invalid_ids_for(user)
    list = user.tasks.map(&:sentence_id)

    list.empty? ? [-1] : list
  end
end
