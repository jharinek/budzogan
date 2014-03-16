class CreateSentences < ActiveRecord::Migration
  def change
    create_table :sentences do |t|
      t.string :content

      t.timestamps
    end
  end
end
