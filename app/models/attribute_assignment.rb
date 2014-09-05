class AttributeAssignment < ActiveRecord::Base
  belongs_to :attribute
  belongs_to :attributable, polymorphic: true
end