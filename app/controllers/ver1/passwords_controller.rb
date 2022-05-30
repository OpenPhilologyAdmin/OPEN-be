# frozen_string_literal: true

module Ver1
  class PasswordsController < ::Devise::PasswordsController
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
  end
end
