class ProcessedTask
  attr_accessor :sentence, :task, :tokens, :relations, :statistics

  def initialize(sentence, task)
    @sentence  = sentence
    @task      = task
    @tokens    = []
    @relations = []
    @stats     = Hash.new
  end
end