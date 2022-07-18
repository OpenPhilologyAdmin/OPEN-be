# frozen_string_literal: true

class AddLastEditorToProjects < ActiveRecord::Migration[7.0]
  def change
    add_reference :projects, :last_editor, index: true
  end
end
