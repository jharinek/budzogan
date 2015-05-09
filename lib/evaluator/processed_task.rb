class ProcessedTask
  attr_accessor :sentence, :task, :tokens, :relations, :statistics, :options

  def initialize(sentence, task)
    @sentence  = sentence
    @task      = task
    @tokens    = []
    @relations = []
    @stats     = Hash.new
    @options   = {}
  end
end