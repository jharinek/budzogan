class AddSolutionToSentences < ActiveRecord::Migration
  def change
    add_column :sentences, :solution, :text
    remove_column :tasks, :solution, :text
  end
end
