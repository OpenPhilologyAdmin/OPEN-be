# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_serializer'

RSpec.configure do |c|
  c.include Helpers::ApparatusSerializer
end

describe Apparatus::EntriesSerializer do
  describe 'as_json' do
    context 'when there are no records' do
      let(:serializer) { described_class.new(records: []) }
      let(:expected_hash) do
        {
          records: [],
          count:   0
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end

    context 'when there are some records' do
      let(:resource) { create(:token, :variant_selected) }
      let(:resource2) { create(:token, :variant_selected_and_secondary) }
      let(:serializer) { described_class.new(records: [resource, resource2], significant:) }
      let(:expected_hash) do
        {
          records: serialized_entries(apparatus_entries),
          count:   2
        }
      end

      context 'when significant readings' do
        let(:significant) { true }
        let(:apparatus_entries) do
          [
            build(:apparatus_significant_entry, token: resource, index: 1),
            build(:apparatus_significant_entry, token: resource2, index: 2)
          ]
        end

        it 'returns hash with correct keys' do
          expect(serializer.as_json).to eq(expected_hash)
        end
      end

      context 'when insignificant readings' do
        let(:significant) { false }
        let(:apparatus_entries) do
          [
            build(:apparatus_insignificant_entry, token: resource, index: 1),
            build(:apparatus_insignificant_entry, token: resource2, index: 2)
          ]
        end

        it 'returns hash with correct keys' do
          expect(serializer.as_json).to eq(expected_hash)
        end
      end
    end
  end
end
