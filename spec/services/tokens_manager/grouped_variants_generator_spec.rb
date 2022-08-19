# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::GroupedVariantsGenerator, type: :service do
  let(:service) { described_class.new(variants) }

  describe '#perform' do
    let(:result) { service.perform }

    context 'when variants empty' do
      let(:variants) { [] }

      it 'returns an empty array' do
        expect(result).to be_empty
      end
    end

    context 'when variants given' do
      let(:variants) do
        [
          build(:token_variant, witness: 'A', t: 'lorim'),
          build(:token_variant, witness: 'B', t: 'lorem'),
          build(:token_variant, witness: 'C', t: 'lorim'),
          build(:token_variant, witness: 'D', t: 'loren')
        ]
      end
      let(:expected_grouped_variants) do
        [
          build(:token_grouped_variant, :insignificant, witnesses: %w[A C], t: 'lorim'),
          build(:token_grouped_variant, :insignificant, witnesses: %w[B], t: 'lorem'),
          build(:token_grouped_variant, :insignificant, witnesses: %w[D], t: 'loren')
        ]
      end

      it 'returns correct grouped variants, with no selections (insignificant)' do
        expect(result).to match_array(expected_grouped_variants)
      end
    end
  end
end
