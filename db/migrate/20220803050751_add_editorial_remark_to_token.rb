# frozen_string_literal: true

class AddEditorialRemarkToToken < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :editorial_remark, :jsonb
  end
end
