# frozen_string_literal: true

module V1
  class SessionsController < ::Devise::SessionsController
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def create
      if empty_login_params?
        handle_empty_login_params
      else
        super
      end
    end

    private

    def empty_login_params?
      resource_params[:password].blank? && resource_params[:email].blank?
    end

    def handle_empty_login_params
      render(
        json:   {
          error: I18n.t('devise.failure.invalid', authentication_keys: 'email')
        },
        status: :unauthorized
      )
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
