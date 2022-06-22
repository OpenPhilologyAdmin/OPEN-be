# frozen_string_literal: true

require 'rails_helper'

describe ProjectSerializer do
  let(:resource) { create(:project) }
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:              resource.id,
        name:            resource.name,
        default_witness: resource.default_witness,
        witnesses:       resource.witnesses,
        status:          resource.status
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
