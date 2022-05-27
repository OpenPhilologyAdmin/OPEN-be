# frozen_string_literal: true

Devise.setup do |config|
  config.mailer_sender = ENV.fetch('DEFAULT_SENDER', nil)
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 12
  config.confirm_within = 3.days
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.paranoid = true

  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key!
  end
end
