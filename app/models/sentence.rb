class Sentence < ActiveRecord::Base
  has_and_belongs_to_many :exercises

  has_many :tasks

  def self.get_bulk(size)
    limit(size)
  end
end
