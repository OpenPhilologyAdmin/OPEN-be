# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WitnessesManager::Creator::TokenProcessor, type: :service do
  let(:service) { described_class.new(token:, siglum:) }
  let(:token) { create(:token) }
  let(:siglum) { 'new-witness-siglum' }

  describe '#add_witness' do
    context 'when variants' do
      before do
        service.add_witness
      end

      it 'uses the current token value as :t for the new variant' do
        added_variant = token.variants.find { |variant| variant.for_witness?(siglum) }
        expect(added_variant.t).to eq(token.current_variant.t)
      end
    end

    context 'when grouped variants' do
      before do
        token.grouped_variants << TokenGroupedVariant.new(t:         token.current_variant.t,
                                                          witnesses: ['nice-witness'],
                                                          selected:  false,
                                                          possible:  false)

        service.add_witness
      end

      it 'updates grouped variants with a new variant' do
        updated_grouped_variant = token.grouped_variants.find { |grouped_variant| grouped_variant.for_witness?(siglum) }

        expect(updated_grouped_variant).not_to be_nil
        expect(updated_grouped_variant.t).to eq(token.current_variant.t)
      end
    end
  end
end
