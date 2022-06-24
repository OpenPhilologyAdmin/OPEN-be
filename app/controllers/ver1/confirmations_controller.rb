# frozen_string_literal: true

module Ver1
  class ConfirmationsController < ::Devise::ConfirmationsController
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
        render(
          json: {
            message: I18n.t('devise.confirmations.confirmed')
          }
        )
      else
        render(
          json:   resource.errors,
          status: :unprocessable_entity
        )
      end
    end

    private

    def notify_admins(record)
      SignupNotifier.new(record).perform!
    end
  end
end
