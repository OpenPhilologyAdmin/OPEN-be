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

    before do
      allow(NotificationMailer).to receive(:new_signup).and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_later)
    end

    context 'when there are no approved admins' do
      it 'does not send any emails' do
        service.perform!
        expect(NotificationMailer).not_to have_received(:new_signup)
      end
    end

    context 'when there are approved admins' do
      let(:admin) { create(:user, :admin, :approved) }

      it 'sends emails to admins' do
        admin
        service.perform!
        expect(NotificationMailer).to have_received(:new_signup).with(new_user, admin)
      end
    end
  end
end
