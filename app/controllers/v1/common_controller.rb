# frozen_string_literal: true

module V1
  class CommonController < ::ApplicationController
    include ApiResponders
    include EditTrackerHelper

    respond_to :json

    before_action :authenticate_user!
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

    def record_not_found
      render json:   {
        error: I18n.t('general.errors.not_found')
      }, status: :not_found
    end
  end
end
