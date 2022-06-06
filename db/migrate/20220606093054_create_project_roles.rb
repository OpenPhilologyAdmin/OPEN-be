# frozen_string_literal: true

class CreateProjectRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :project_roles do |t|
      t.integer :project_id, index: true
      t.integer :user_id, index: true
      t.string :role
      t.timestamps
    end
  end
end
