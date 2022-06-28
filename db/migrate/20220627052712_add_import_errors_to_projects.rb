# frozen_string_literal: true

class AddImportErrorsToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :import_errors, :jsonb, default: {}
  end
end
