# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

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
  config.parent_controller = 'V1::CommonController'

  config.jwt do |jwt|
    jwt.secret = ENV.fetch('DEVISE_JWT_SECRET_KEY', '')
    jwt.expiration_time = 21_600 # 6 hours
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/users/sign_in$}],
      ['PUT', %r{^/api/v1/users/password$}],
      ['POST', %r{^/api/v1/users/session-token$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/users/sign_out$}]
    ]
  end
end
# rubocop:enable Metrics/BlockLength
