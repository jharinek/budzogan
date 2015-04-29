class Relation
  attr_accessor :source, :target, :type, :reference

  def initialize(source, target, type)
    @source = source
    @target = target
    @type   = type
  end
end