# frozen_string_literal: true

require 'rails_helper'

describe UsersSerializer do
  let(:resource) { create(:user) }
  let(:resource2) { create(:user) }
  let(:serializer) { described_class.new([resource, resource2]) }
  let(:metadata) do
    {
      count: 25,
      page:  2,
      pages: 3
    }
  end

  describe 'as_json' do
    context 'when metadata not given' do
      let(:expected_hash) do
        {
          records:      [UserSerializer.new(resource).as_json, UserSerializer.new(resource2).as_json],
          count:        2,
          current_page: 1,
          pages:        1
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end

    context 'when metadata is given' do
      let(:serializer) { described_class.new([resource, resource2], metadata:) }

      let(:expected_hash) do
        {
          records:      [UserSerializer.new(resource).as_json, UserSerializer.new(resource2).as_json],
          count:        metadata[:count],
          current_page: metadata[:page],
          pages:        metadata[:pages]
        }
      end

      it 'returns hash with correct keys' do
        expect(serializer.as_json).to eq(expected_hash)
      end
    end
  end
end
