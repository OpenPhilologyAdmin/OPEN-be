# frozen_string_literal: true

module Ver1
  class ApiApplicationController < ::ApplicationController
    respond_to :json

    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :forbidden_request

    def forbidden_request
      render(
        json:      {
          success: false,
          message: 'Not authorized to perform this action.'
        }, status: :forbidden
      )
    end
  end
end
