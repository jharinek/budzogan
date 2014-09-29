class AddDistributionStrategyToExercise < ActiveRecord::Migration
  def change
    add_column :exercises, :distribution_strategy, :string, null: false, default: ''
    add_column :exercises, :distributed, :boolean, null: false, default: false
  end
end
