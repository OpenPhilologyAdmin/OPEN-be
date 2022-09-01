# frozen_string_literal: true

module TokensManager
  class Updater < Base
    def perform
      success = update_token
      update_last_editor if success

      Result.new(success:, token:)
    end

    private

    delegate :project, to: :token

    def update_token
      raise NotImplementedError
    end

    def update_last_editor
      project.update(last_editor: user)
    end
  end
end
