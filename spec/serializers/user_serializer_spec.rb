# frozen_string_literal: true

require 'rails_helper'

describe UserSerializer do
  let(:resource) { create(:user) }
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:                resource.id,
        email:             resource.email,
        name:              resource.name,
        role:              resource.role,
        account_approved:  resource.account_approved?,
        registration_date: resource.registration_date
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
