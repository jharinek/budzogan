class CreateWorkGroups < ActiveRecord::Migration
  def change
    create_table :work_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
