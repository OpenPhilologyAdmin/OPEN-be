# frozen_string_literal: true

require 'rails_helper'

describe TokenSerializer do
  let(:resource) { create(:token, apparatus_index: 1) }
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:              resource.id,
        t:               resource.t,
        apparatus_index: resource.apparatus_index
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
