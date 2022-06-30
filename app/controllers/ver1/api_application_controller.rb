# frozen_string_literal: true

module Ver1
  class ApiApplicationController < ::ApplicationController
    include ApiResponders

    respond_to :json

    after_action :verify_authorized

    rescue_from Pundit::NotAuthorizedError, with: :forbidden_request
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    def forbidden_request
      render(
        json:      {
          error: I18n.t('general.errors.forbidden_request')
        }, status: :forbidden
      )
    end

    def require_login
      return if current_user

      render json:   {
        error: I18n.t('general.errors.login_required')
      }, status: :unauthorized
    end

    def record_not_found
      render json:   {
        error: I18n.t('general.errors.not_found')
      }, status: :not_found
    end
  end
end
