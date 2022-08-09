# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry_dsn
  config.environment = ENV.fetch('ENVIRONMENT_NAME', 'production')
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.traces_sampler = lambda do |sampling_context|
    next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

    0.2
  end
end
