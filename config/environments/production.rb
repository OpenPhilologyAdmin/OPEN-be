# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.active_storage.service = :dokku_storage
  config.force_ssl = true
  config.log_level = :info
  config.log_tags = [:request_id]
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.log_formatter = Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  config.action_mailer.smtp_settings = {
    user_name:            ENV.fetch('SENDGRID_USER_NAME'),
    password:             ENV.fetch('SENDGRID_PASSWORD'),
    domain:               ENV.fetch('APP_HOST', nil),
    address:              'smtp.sendgrid.net',
    port:                 '587',
    authentication:       :plain,
    enable_starttls_auto: true
  }

  config.require_master_key = false
end
