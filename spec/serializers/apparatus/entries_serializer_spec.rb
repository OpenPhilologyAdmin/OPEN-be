# frozen_string_literal: true

require 'rails_helper'

describe Apparatus::EntriesSerializer do
  describe 'as_json' do
    let(:serializer) { described_class.new(records: []) }
    let(:expected_hash) do
      {
        records: [],
        count:   0
      }
    end

    it 'raises NotImplementedError' do
      expect { serializer.as_json }.to raise_error(NotImplementedError)
    end
  end
end
