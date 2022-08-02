# frozen_string_literal: true

require 'rails_helper'

describe TokensSerializer do
  describe 'as_json' do
    context 'when there are no records' do
      let(:serializer) { described_class.new([]) }
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
      let(:resource2) { create(:token) }
      let(:resource3) { create(:token, :variant_selected) }
      let(:serialized_records) { serializer.as_json[:records] }

      context 'without options given' do
        let(:serializer) { described_class.new([resource, resource2, resource3]) }
        let(:expected_hash) do
          {
            records: [
              TokenSerializer.new(resource).as_json,
              TokenSerializer.new(resource2).as_json,
              TokenSerializer.new(resource3).as_json
            ],
            count:   3
          }
        end

        it 'returns hash with correct keys' do
          expect(serializer.as_json).to eq(expected_hash)
        end

        it 'assigns correct :apparatus_index when available' do
          serialized_record = serialized_records.find { |r| r['id'] == resource.id }
          expect(serialized_record['apparatus_index']).to eq(1)
          serialized_record = serialized_records.find { |r| r['id'] == resource3.id }
          expect(serialized_record['apparatus_index']).to eq(2)
        end

        it 'leaves :apparatus_index nil when not available' do
          serialized_record = serialized_records.find { |r| r['id'] == resource2.id }
          expect(serialized_record['apparatus_index']).to be_nil
        end
      end

      context 'with specific mode enabled' do
        let(:mode) { :edit_project }
        let(:serializer) do
          described_class.new(
            [resource, resource2, resource3],
            mode:
          )
        end
        let(:expected_hash) do
          {
            records: [
              TokenSerializer.new(resource, mode:).as_json,
              TokenSerializer.new(resource2, mode:).as_json,
              TokenSerializer.new(resource3, mode:).as_json
            ],
            count:   3
          }
        end

        it 'returns hash with correct keys' do
          expect(serializer.as_json).to eq(expected_hash)
        end

        it 'assigns correct :apparatus_index when available' do
          serialized_record = serialized_records.find { |r| r['id'] == resource.id }
          expect(serialized_record['apparatus_index']).to eq(1)
          serialized_record = serialized_records.find { |r| r['id'] == resource3.id }
          expect(serialized_record['apparatus_index']).to eq(2)
        end

        it 'leaves :apparatus_index nil when not available' do
          serialized_record = serialized_records.find { |r| r['id'] == resource2.id }
          expect(serialized_record['apparatus_index']).to be_nil
        end

        it 'includes :state' do
          expect(serialized_records).to all(have_key('state'))
        end
      end
    end
  end
end
