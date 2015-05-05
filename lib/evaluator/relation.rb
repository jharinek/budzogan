class Relation
  attr_accessor :source, :target, :type, :reference

  def initialize(source, target, type)
    @source = source
    @target = target
    @type   = type
  end

  def equals?(relation)
    return true if self.target == relation.target && self.source == relation.source && self.type == relation.type
    return true if self.target == relation.source && self.source == relation.target && self.type == relation.type

    false
  end

  def equal_elements?(relation)
    return true if self.target == relation.target && self.source == relation.source
    return true if self.target == relation.source && self.source == relation.target

    false
  end
end