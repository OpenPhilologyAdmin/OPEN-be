# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('DEFAULT_SENDER', nil)
  layout 'mailer'
end
