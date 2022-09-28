# frozen_string_literal: true

class AddDeletedToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :deleted, :boolean, default: false
  end
end
