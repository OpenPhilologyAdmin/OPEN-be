# frozen_string_literal: true

class AddResizedToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :resized, :boolean, default: false
  end
end
