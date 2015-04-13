class AddLengthAndTaskCounterToSentences < ActiveRecord::Migration
  def change
    add_column  :sentences, :length, :integer
    add_counter :sentences, :tasks
    add_index   :sentences, :length
  end

end
