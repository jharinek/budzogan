class TasksProcessor
  def initialize(factory, properties = [])
    @factory    = factory
    @properties = properties
  end

  def load_tasks
    @tasks = Task.where(@properties)
  end

  def process_tasks
    @processed_tasks = []

    @task.each do |t|
      @processed_tasks << @factory.create(t.process)
    end
  end
end