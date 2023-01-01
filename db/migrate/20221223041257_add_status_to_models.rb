class AddStatusToModels < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :status, :integer, default: 0
    add_column :sections, :status, :integer, default: 0
    add_column :tasks, :status, :integer, default: 0
  end
end
