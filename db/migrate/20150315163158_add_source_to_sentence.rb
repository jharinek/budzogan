class AddSourceToSentence < ActiveRecord::Migration
  def change
    add_column :sentences, :source, :string

    add_index :sentences, :source
  end
end
