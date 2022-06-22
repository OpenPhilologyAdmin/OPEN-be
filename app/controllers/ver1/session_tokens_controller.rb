# frozen_string_literal: true

module Ver1
  class SessionTokensController < ApiApplicationController
    before_action :require_login

    def create
      authorize :session_token, :create?

      head :no_content
    end
  end
end
