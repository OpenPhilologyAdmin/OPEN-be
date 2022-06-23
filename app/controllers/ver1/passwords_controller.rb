# frozen_string_literal: true

module Ver1
  class PasswordsController < ::Devise::PasswordsController
    include ::RackSessionFix

    prepend_before_action :require_no_authentication

    def create
      User.send_reset_password_instructions(resource_params)
      render(
        json:   {
          message: I18n.t('devise.passwords.send_paranoid_instructions')
        },
        status: :ok
      )
    end

    def update
      self.resource = User.reset_password_by_token(resource_params)

      if resource.errors.empty?
        unlock_and_sign_in
        render(
          json:   {
            message: I18n.t('devise.passwords.updated')
          },
          status: :ok
        )
      else
        render(
          json:   resource.errors,
          status: :unprocessable_entity
        )
      end
    end

    private

    def unlock_and_sign_in
      resource.unlock_access! if unlockable?(resource)
      sign_in(:user, resource)
    end
  end
end
