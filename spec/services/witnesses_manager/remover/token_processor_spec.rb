# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Remover::TokenProcessor, type: :service do
  let(:service) { described_class.new(token:, siglum:) }
  let(:siglum) { 'A' }

  describe '#remove_witness' do
    before do
      service.remove_witness
    end

    context 'when variants' do
      let(:variant) { build(:token_variant, witness: siglum) }
      let(:token) { build(:token, variants: [variant]) }

      it 'deletes the variant with given siglum' do
        expect(token.variants).not_to include(variant)
      end
    end

    context 'when grouped variants' do
      let(:token) { build(:token, grouped_variants: [grouped_variant]) }

      context 'when the grouped variant has only the removed witness' do
        let(:grouped_variant) { build(:token_grouped_variant, witnesses: [siglum]) }

        it 'deletes the variant with given siglum' do
          expect(token.grouped_variants).not_to include(grouped_variant)
        end
      end

      context 'when the grouped variant has more than one witness' do
        let(:grouped_variant) { build(:token_grouped_variant, witnesses: [siglum, 'B']) }

        it 'does not remove the whole grouped variant' do
          expect(token.grouped_variants).to include(grouped_variant)
        end

        it 'deletes the given witness from the grouped_variant' do
          expect(grouped_variant.witnesses).not_to include(siglum)
        end
      end

      context 'when there are no grouped variants for given siglum' do
        let(:grouped_variant) { build(:token_grouped_variant, witnesses: ['B']) }

        it 'does not change any grouped variants' do
          expect(token.grouped_variants).to match_array([grouped_variant])
        end
      end
    end
  end
end
