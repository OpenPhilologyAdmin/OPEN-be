# frozen_string_literal: true

require 'rails_helper'

describe Apparatus::EntrySerializer do
  let(:resource) { create(:apparatus_entry, :variant_selected) }
  let(:serializer) { described_class.new(resource) }

  describe '#as_json' do
    let(:expected_hash) do
      {
        token_id: resource.token_id,
        index:    resource.index,
        value:    resource.value
      }.as_json
    end

    it 'returns hash with specified keys' do
      expect(serializer.as_json).to eq(expected_hash)
    end
  end
end
