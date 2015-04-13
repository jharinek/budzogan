class CreateExercisesSentencesJoiningTable < ActiveRecord::Migration
  def change
    create_table :exercises_sentences, id: false do |t|
      t.references :exercise
      t.references :sentence
    end
  end
end
