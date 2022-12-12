# frozen_string_literal: true

module TokensManager
  class Updater < Base
    include EditTrackerHelper

    def perform
      success = update_token

      Result.new(success:, token:)
    end

    private

    delegate :project, to: :token

    def update_token
      raise NotImplementedError
    end
  end
end
