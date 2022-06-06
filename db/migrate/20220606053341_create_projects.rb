# frozen_string_literal: true

class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :user_id, index: true
      t.string :default_witness
      t.jsonb :witnesses

      t.timestamps
    end
  end
end
