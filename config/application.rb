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
require 'action_mailbox/engine'
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

    if ENV['ENVIRONMENT_NAME'].present?
      filename = Rails.root.join('config', 'credentials', ENV['ENVIRONMENT_NAME'])
      config.credentials.content_path = "#{filename}.yml.enc"

      config.credentials.key_path = "#{filename}.key" if File.exist? "#{filename}.key"
    end
    config.active_job.queue_adapter = :sidekiq
  end
end
