# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CollationBe
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Amsterdam'
    config.api_only = true
    config.active_job.queue_adapter = :sidekiq

    # ensure the API uses ISO 8601 date and time format
    ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
  end
end
