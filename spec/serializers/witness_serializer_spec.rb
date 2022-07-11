# frozen_string_literal: true

require 'rails_helper'

describe WitnessSerializer do
  let(:resource) { build(:witness, :with_project) }
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:      resource.id,
        default: resource.default?,
        name:    resource.name,
        siglum:  resource.siglum
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
