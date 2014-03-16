class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.integer :template_id
      t.integer :group_id

      t.integer :sentence_length
      t.string :sentence_difficulty
      t.string :sentence_source

      t.timestamps
    end

    add_index :exercises, :template_id
    add_index :exercises, :group_id
  end
end
