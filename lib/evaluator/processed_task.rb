class ProcessedTask
  attr_accessor :sentence, :task, :tokens

  def initialize(sentence, task)
    @sentence = sentence
    @task     = task
    @tokens   = []
  end
end