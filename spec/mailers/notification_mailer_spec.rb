# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  let(:default_sender) { ENV.fetch('DEFAULT_SENDER', nil) }

  describe '#new_signup' do
    let(:mail) { described_class.new_signup(user, recipient) }
    let(:user) { create(:user) }
    let(:recipient) { create(:user) }

    it 'renders correct subject' do
      expect(mail.subject).to eq(I18n.t('mailers.notification_mailer.new_signup.subject'))
    end

    it 'sets correct recipient' do
      expect(mail.to).to eq([recipient.email])
    end

    it 'sets correct sender' do
      expect(mail.from).to eq([default_sender])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(I18n.t('mailers.notification_mailer.new_signup.message'))
    end
  end
end
