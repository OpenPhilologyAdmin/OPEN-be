# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SignupNotifier, type: :service do
  let(:service) { described_class.new(new_user) }
  let(:new_user) { create(:user, :not_approved) }

  describe '#initialize' do
    it 'sets @new_user' do
      expect(service.instance_variable_get('@new_user')).to eq(new_user)
    end
  end

  describe '#perform!' do
    let(:mailer_mock) { instance_double(ActionMailer::MessageDelivery) }
    let(:expected_recipient_email) { ENV.fetch('SIGNUP_NOTIFICATION_RECIPIENT', nil) }

    before do
      allow(NotificationMailer).to receive(:new_signup).and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_later)
      service.perform!
    end

    it 'sends email to specified recipient' do
      expect(NotificationMailer).to have_received(:new_signup).with(
        new_user:,
        recipient_email: expected_recipient_email
      )
    end
  end
end
