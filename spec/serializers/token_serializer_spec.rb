# frozen_string_literal: true

require 'rails_helper'

describe TokenSerializer do
  let(:resource) { create(:token, apparatus_index: 1) }

  context 'when no additional flag enabled' do
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

  context 'when :edit_mode enabled' do
    let(:serializer) { described_class.new(resource, edit_mode: true) }
    let(:expected_hash) do
      {
        id:              resource.id,
        t:               resource.t,
        apparatus_index: resource.apparatus_index,
        state:           resource.state
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end

  context 'when :verbose enabled' do
    let(:serializer) { described_class.new(resource, verbose: true) }

    describe '#as_json' do
      let(:expected_hash) do
        {
          id:               resource.id,
          grouped_variants: resource.grouped_variants
        }.as_json
      end

      it 'returns hash with specified keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
