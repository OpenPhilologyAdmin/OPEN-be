# frozen_string_literal: true

class CreateTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :tokens do |t|
      t.references :project
      t.integer :index
      t.jsonb :variants
      t.jsonb :grouped_variants
      t.timestamps
    end
  end
end
