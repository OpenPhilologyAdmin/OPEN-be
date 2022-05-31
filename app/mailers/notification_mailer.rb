# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_signup(new_user, recipient)
    @new_user = new_user
    @recipient = recipient

    mail(to: @recipient.email, subject: I18n.t('mailers.notification_mailer.new_signup.subject'))
  end
end
