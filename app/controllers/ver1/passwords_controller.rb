# frozen_string_literal: true

module Ver1
  class PasswordsController < ::Devise::PasswordsController
    include ::RackSessionFix

    skip_after_action :verify_authorized
    prepend_before_action :require_no_authentication

    def create
      record = User.send_reset_password_instructions(resource_params)
      record.valid?
      if record.errors[:email].empty?
        render(
          json:   {
            message: I18n.t('devise.passwords.send_paranoid_instructions')
          },
          status: :ok
        )
      else
        # Respond with email-related errors
        render(
          json:   record_errors(record).slice(:email),
          status: :unprocessable_entity
        )
      end
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
        respond_with_record_errors(resource, :unprocessable_entity)
      end
    end

    private

    def unlock_and_sign_in
      resource.unlock_access! if unlockable?(resource)
      sign_in(:user, resource)
    end
  end
end
