# frozen_string_literal: true

class AddStatusToProject < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :status, :string
  end
end
