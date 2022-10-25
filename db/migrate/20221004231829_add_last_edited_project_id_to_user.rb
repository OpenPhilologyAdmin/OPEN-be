# frozen_string_literal: true

class AddLastEditedProjectIdToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :last_edited_project, index: true
  end
end
