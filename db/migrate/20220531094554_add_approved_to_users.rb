# frozen_string_literal: true

class AddApprovedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :approved_at, :datetime
  end
end
