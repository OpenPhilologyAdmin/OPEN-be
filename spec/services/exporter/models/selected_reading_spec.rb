# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_export'

RSpec.configure do |c|
  c.include Helpers::ApparatusExport
end

RSpec.describe Exporter::Models::SelectedReading, type: :model do
  let(:resource) { described_class.new(selected_variant:, separator:) }
  let(:separator) { ',' }

  describe '#reading' do
    let(:selected_variant) { build(:token_grouped_variant, :selected) }
    let(:expected_value) do
      selected_grouped_variant_value(grouped_variant: selected_variant, separator:)
    end

    it 'returns the correct reading' do
      expect(resource.reading).to eq(expected_value)
    end
  end

  describe '#witnesses' do
    let(:selected_variant) { build(:token_grouped_variant, :selected) }
    let(:expected_value) do
      selected_variant.formatted_witnesses
    end

    it 'returns the witnesses' do
      expect(resource.witnesses).to eq(expected_value)
    end
  end
end
