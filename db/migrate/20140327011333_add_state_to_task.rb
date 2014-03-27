class AddStateToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :state, :integer, null: false, default: 0
  end
end
