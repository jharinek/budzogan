class Token
  attr_accessor :text, :properties, :relations

  def initialize(text)
    text.gsub!('.', '')
    text.gsub!('!', '')
    text.gsub!('?', '')
    text.gsub!(',', '')
    text.gsub!(';', '')
    @text        = text
    @properties  = []
    @relations   = []
  end
end