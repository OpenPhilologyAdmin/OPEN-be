# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_export'

RSpec.configure do |c|
  c.include Helpers::ApparatusExport
end

RSpec.describe Exporter::Models::AdditionalReadings, type: :model do
  describe '#reading' do
    let(:resource) { described_class.new(grouped_variants:, separator:) }
    let(:separator) { ',' }

    context 'when there are multiple grouped variants given' do
      let(:grouped_variants) { [build(:token_grouped_variant), build(:token_grouped_variant)] }
      let(:expected_value) { grouped_variants_to_export(grouped_variants:, separator:) }

      it 'returns the correct reading' do
        expect(resource.reading).to eq(expected_value)
      end
    end

    context 'when there is just one grouped variants given' do
      let(:grouped_variants) { [build(:token_grouped_variant)] }
      let(:expected_value) { grouped_variants_to_export(grouped_variants:, separator:) }

      it 'returns the correct reading' do
        expect(resource.reading).to eq(expected_value)
      end
    end

    context 'when there are no grouped variants given' do
      let(:grouped_variants) { [] }
      let(:expected_value) { '' }

      it 'returns an empty string' do
        expect(resource.reading).to eq(expected_value)
      end
    end
  end
end
