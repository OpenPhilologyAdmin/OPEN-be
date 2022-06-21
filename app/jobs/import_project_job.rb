# frozen_string_literal: true

class ImportProjectJob < ApplicationJob
  queue_as :default

  def perform(project_id, user_id)
    project = Project.find(project_id)
    user = User.find(user_id)

    return unless project.status.processing?

    Importer::Base.new(project:, user:).process
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
