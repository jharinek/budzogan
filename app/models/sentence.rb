class Sentence < ActiveRecord::Base
  serialize :solution, Hash

  has_and_belongs_to_many :exercises

  has_many :tasks

  scope :starters, lambda{ |bulk_size| order(id: :asc).limit(bulk_size) }
  scope :needed,   lambda{ |ids_list| order(id: :asc).where('tasks_count < 40').where('id not in (?)', ids_list) }

  scope :long,   lambda{ |count| where('length > 10').limit(count) }
  scope :medium, lambda{ |count| where('length > 5').where('length < 11').limit(count) }
  scope :short,  lambda{ |count| where('length < 6').limit(count) }

  before_create :compute_length

  def self.get_bulk(size, assignee)
    tasks_pool = self.needed(invalid_ids_for(assignee))
    sentences = []

    if assignee.tasks.count == 0
      size -= 4
    end

    remaining = size
    bulk_size = size/3

    tasks_pool.long(bulk_size).each { |s| sentences << s }
    remaining -= bulk_size
    tasks_pool.medium(bulk_size).each { |s| sentences << s }
    remaining -= bulk_size
    tasks_pool.short(remaining).each { |s| sentences << s }

    if assignee.tasks.count == 0
      self.starters(4).each { |s| sentences << s }
    end
    
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
