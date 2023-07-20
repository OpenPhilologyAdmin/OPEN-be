# frozen_string_literal: true

class SignupNotifier
  SIGNUP_NOTIFICATION_RECIPIENT = ENV.fetch('SIGNUP_NOTIFICATION_RECIPIENT', nil)

  def initialize(new_user)
    @new_user = new_user
  end

  def perform!
    NotificationMailer.new_signup(
      new_user:,
      recipient_email: SIGNUP_NOTIFICATION_RECIPIENT
    ).deliver_later
  end

  private

  attr_reader :new_user
end
