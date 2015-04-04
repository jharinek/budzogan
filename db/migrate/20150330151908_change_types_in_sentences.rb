class ChangeTypesInSentences < ActiveRecord::Migration
  def change
    change_column :sentences, :content, :text
    change_column :sentences, :source, :text
  end
end
