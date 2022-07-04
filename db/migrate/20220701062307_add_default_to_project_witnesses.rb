# frozen_string_literal: true

class AddDefaultToProjectWitnesses < ActiveRecord::Migration[7.0]
  def up
    change_column :projects, :witnesses, :jsonb, default: {}
  end

  def down
    change_column :projects, :witnesses, :jsonb, default: nil
  end
end
