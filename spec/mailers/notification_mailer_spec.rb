# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer do
  let(:default_sender) { ENV.fetch('DEFAULT_SENDER', nil) }

  describe '#new_signup' do
    let(:mail) { described_class.new_signup(new_user:, recipient_email:) }
    let(:new_user) { create(:user) }
    let(:recipient_email) { Faker::Internet.email }

    it 'renders correct subject' do
      expect(mail.subject).to eq(I18n.t('mailers.notification_mailer.new_signup.subject'))
    end

    it 'sets correct recipient' do
      expect(mail.to).to eq([recipient_email])
    end

    it 'sets correct sender' do
      expect(mail.from).to eq([default_sender])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(I18n.t('mailers.notification_mailer.new_signup.message'))
    end
  end

  describe '#account_approved' do
    let(:mail) { described_class.account_approved(recipient) }
    let(:recipient) { create(:user) }

    it 'renders correct subject' do
      expect(mail.subject).to eq(I18n.t('mailers.notification_mailer.account_approved.subject'))
    end

    it 'sets correct recipient' do
      expect(mail.to).to eq([recipient.email])
    end

    it 'sets correct sender' do
      expect(mail.from).to eq([default_sender])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include(I18n.t('mailers.notification_mailer.account_approved.message'))
    end
  end
end
