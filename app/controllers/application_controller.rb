# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization
  include Pagy::Backend
  before_action :set_sentry_context

  # :nocov:
  def set_sentry_context
    return unless Rails.application.credentials.sentry_dsn

    Sentry.set_extras(url: request.url)
    return unless user_signed_in?

    Sentry.set_user(
      id:    current_user.id,
      email: current_user.email
    )
  end
end
