# frozen_string_literal: true

require 'rails_helper'

describe TokenSerializer do
  let(:resource) { create(:token, apparatus_index: 1) }

  describe '#as_json' do
    context 'when :edit_mode not enabled' do
      let(:serializer) { described_class.new(resource) }
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
  end
end
