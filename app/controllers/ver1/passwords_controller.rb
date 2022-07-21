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
      else
        respond_with_record_errors(resource, :unprocessable_entity)
      end
    end

    private

    def unlock_and_sign_in
      resource.unlock_access! if unlockable?(resource)
      if resource.active_for_authentication?
        handle_active_user
      else
        handle_inactive_user
      end
    end

    def handle_active_user
      sign_in(:user, resource)
      render(
        json:   {
          message: I18n.t('devise.passwords.updated')
        },
        status: :ok
      )
    end

    def handle_inactive_user
      render(
        json:   {
          error: I18n.t("devise.passwords.updated_not_active_#{resource.inactive_message}")
        },
        status: :unauthorized
      )
    end
  end
end
