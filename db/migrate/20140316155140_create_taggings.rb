class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :tag_id
      t.integer :template_id

      t.string :type

      t.timestamps
    end

    add_index :taggings, :tag_id
    add_index :taggings, :template_id
  end
end
