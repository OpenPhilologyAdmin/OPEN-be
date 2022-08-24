# frozen_string_literal: true

module V1
  class ConfirmationsController < ::Devise::ConfirmationsController
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def create
      self.resource = User.send_confirmation_instructions(resource_params)

      render(
        json: {
          message: I18n.t('devise.confirmations.send_paranoid_instructions')
        }
      )
    end

    def show
      self.resource = User.confirm_by_token(params[:confirmation_token])

      if resource.errors.empty?
        notify_admins(resource)
        message_key = resource.active_for_authentication? ? 'confirmed' : 'confirmed_but_not_approved'
        render(
          json: {
            message: I18n.t("devise.confirmations.#{message_key}")
          }
        )
      else
        respond_with_confirmation_token_error(resource)
      end
    end

    private

    def notify_admins(record)
      return if record.account_approved?

      SignupNotifier.new(record).perform!
    end

    # assign all errors to :confirmation_token field
    def respond_with_confirmation_token_error(resource)
      render(
        json:   {
          confirmation_token: resource.errors.full_messages
        },
        status: :unprocessable_entity
      )
    end
  end
end
