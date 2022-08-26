# frozen_string_literal: true

require 'rails_helper'

describe TokenSerializer do
  let(:resource) { create(:token, :variant_selected, apparatus_index: 1) }

  context 'when no special mode enabled' do
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

  context 'when invalid mode given' do
    let(:serializer) { described_class.new(resource, mode: :lorem_ipsum) }

    describe '#as_json' do
      let(:expected_hash) do
        {
          id:              resource.id,
          t:               resource.t,
          apparatus_index: resource.apparatus_index
        }.as_json
      end

      it 'returns hash with :standard keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end

  context 'when :edit_project mode' do
    let(:serializer) { described_class.new(resource, mode: :edit_project) }
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

  context 'when :edit_token mode' do
    let(:serializer) { described_class.new(resource, mode: :edit_token) }

    describe '#as_json' do
      let(:expected_hash) do
        {
          id:               resource.id,
          apparatus:        resource.apparatus,
          grouped_variants: resource.grouped_variants,
          variants:         resource.variants,
          editorial_remark: resource.editorial_remark
        }.as_json
      end

      it 'returns hash with specified keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
