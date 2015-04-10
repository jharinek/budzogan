class AddSexAndEvaluationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sex,        :string, null: true
    add_column :users, :evaluation, :string, null: true
  end
end
