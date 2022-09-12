# frozen_string_literal: true

class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.string :body, limit: 250
      t.references :token
      t.references :user
      t.timestamps
    end
  end
end
