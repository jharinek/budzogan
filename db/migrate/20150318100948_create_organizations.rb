class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :category
      t.string :address
    end

    add_index :organizations, :name
    add_index :organizations, :category
  end
end
