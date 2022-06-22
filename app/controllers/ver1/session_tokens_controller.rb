# frozen_string_literal: true

module Ver1
  class SessionTokensController < ApiApplicationController
    before_action :require_login

    # the new token will be available in response headers
    # for more details see: config/initializers/devise.rb
    def create
      authorize :session_token, :create?

      head :no_content
    end
  end
end
