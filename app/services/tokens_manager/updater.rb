# frozen_string_literal: true

module TokensManager
  class Updater < Base
    include EditTrackerHelper

    def perform
      success = update_token
      edit_tracking_info if success

      Result.new(success:, token:)
    end

    private

    delegate :project, to: :token

    def update_token
      raise NotImplementedError
    end

    def edit_tracking_info
      update_last_editor(user:, project:)
      update_last_edited_project(project:, user:)
    end
  end
end
