# frozen_string_literal: true

class ImportProjectJob < ApplicationJob
  queue_as :default

  def perform(project_id, user_id, default_witness_name = nil)
    project = Project.find(project_id)
    user = User.find(user_id)

    return unless project.status.processing?

    Importer::Base.new(project:, user:, default_witness_name:).process
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
