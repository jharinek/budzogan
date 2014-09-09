class ElementAssignment < ActiveRecord::Base
  belongs_to :element
  belongs_to :elementable, polymorphic: true
end