# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def new_signup(new_user:, recipient_email:)
    @new_user = new_user
    @recipient_email = recipient_email

    mail(to: @recipient_email, subject: I18n.t('mailers.notification_mailer.new_signup.subject'))
  end

  def account_approved(recipient)
    @recipient = recipient

    mail(to: @recipient.email, subject: I18n.t('mailers.notification_mailer.account_approved.subject'))
  end
end
