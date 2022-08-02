# frozen_string_literal: true

module TokensManager
  class Updater < Base
    def perform!
      success = @token.update(@params)
      update_last_editor if success

      Result.new(
        success:,
        token:   @token
      )
    end

    private

    def update_last_editor
      @token.project.update(last_editor: @user)
    end
  end
end
