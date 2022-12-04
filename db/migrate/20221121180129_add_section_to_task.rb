class AddSectionToTask < ActiveRecord::Migration[7.0]
  def change
    add_reference :tasks, :section, null: false, foreign_key: true
  end
end
