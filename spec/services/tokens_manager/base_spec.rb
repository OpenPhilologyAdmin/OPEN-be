# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Base, type: :service do
  let(:user) { create(:user, :admin, :approved) }
  let(:token) { create(:token) }
  let(:params) { {} }
  let(:service) { described_class.new(token:, user:, params:) }

  describe '#perform' do
    it 'raises NotImplementedError by default' do
      expect { service.perform }.to raise_error(NotImplementedError)
    end
  end

  describe 'self.perform' do
    let(:instance_mock) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(instance_mock)
      allow(instance_mock).to receive(:perform)
      described_class.perform(token:, user:, params:)
    end

    it 'initializes new instance with given options' do
      expect(described_class).to have_received(:new).with(token:, user:, params:)
    end

    it 'runs perform! on the new instance' do
      expect(instance_mock).to have_received(:perform)
    end
  end
end
