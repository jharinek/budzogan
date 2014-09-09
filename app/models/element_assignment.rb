class ElementAssignment < ActiveRecord::Base
  belongs_to :element
  belongs_to :attributable, polymorphic: true
end