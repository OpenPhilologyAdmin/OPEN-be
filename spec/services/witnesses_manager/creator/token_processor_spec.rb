# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Creator::TokenProcessor, type: :service do
  let(:service) { described_class.new(token:, siglum:) }
  let(:token) { create(:token) }
  let(:siglum) { 'new-witness-siglum' }

  describe '#remove_witness' do
    before do
      allow(TokensManager::GroupedVariantsGenerator).to receive(:perform).and_call_original
      service.add_witness
    end

    context 'when variants' do
      it 'uses the current token value as :t for the new variant' do
        added_variant = token.variants.find { |variant| variant.for_witness?(siglum) }
        expect(added_variant.t).to eq(token.current_variant.t)
      end
    end

    context 'when grouped variants' do
      it 'uses GroupedVariantsGenerator to recalculate grouped variants' do
        expect(TokensManager::GroupedVariantsGenerator).to have_received(:perform)
          .with(token:)
      end

      it 'adds variant to the grouped variants' do
        updated_grouped_variant = token.grouped_variants.find { |grouped_variant| grouped_variant.for_witness?(siglum) }
        expect(updated_grouped_variant).not_to be_nil
        expect(updated_grouped_variant.t).to eq(token.current_variant.t)
      end
    end
  end
end
