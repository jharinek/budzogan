class ProcessedTask
  attr_accessor :sentence, :task, :tokens, :relations

  def initialize(sentence, task)
    @sentence  = sentence
    @task      = task
    @tokens    = []
    @relations = []
  end
end