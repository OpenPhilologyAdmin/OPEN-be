# frozen_string_literal: true

require 'rails_helper'

describe WitnessSerializer do
  let(:record) { build(:witness, :with_project) }
  let(:serializer) { described_class.new(record:) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        id:      record.id,
        default: record.default?,
        name:    record.name,
        siglum:  record.siglum
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
