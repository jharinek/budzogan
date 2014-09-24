class ElementAssignment < ActiveRecord::Base
  belongs_to :element
  belongs_to :elementable, polymorphic: true

  validates_uniqueness_of :element_id, scope: [:elementable_id]
end