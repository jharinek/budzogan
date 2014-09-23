class FixValuesAndPopulateNewFieldsInModels < ActiveRecord::Migration
  def change
    Task.all.each do |task|
      task.state = 0

      task.save!
    end

    Exercise.all.each do |exercise|
      exercise.status = :new
      exercise.description = ''

      exercise.sentence_length     = 5
      exercise.sentence_difficulty = :easy

      exercise.save!
    end

    Element.all.each do |element|
      element.category = ''

      element.save!
    end
  end
end
