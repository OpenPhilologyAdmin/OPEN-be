# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensResizer::SelectionsCopier, type: :service do
  let(:service) { described_class.new(target_token:, source_token:) }

  describe '#perform' do
    before { service.perform }

    context 'when selected grouped variants empty' do
      let(:source_token) { build(:token, grouped_variants: []) }
      let(:target_token) { build(:token) }

      it 'does not select any grouped variants' do
        expect(target_token.grouped_variants).to all(be_insignificant)
      end
    end

    context 'when selected grouped variants given' do
      let(:source_token) do
        build(:token,
              grouped_variants: [
                build(:token_grouped_variant, :selected, witnesses: %w[A B]),
                build(:token_grouped_variant, :secondary, witnesses: %w[C]),
                build(:token_grouped_variant, :insignificant, witnesses: %w[D])
              ])
      end
      let(:target_token) do
        build(:token,
              grouped_variants: [
                build(:token_grouped_variant, :insignificant, witnesses: %w[B A]),
                build(:token_grouped_variant, :insignificant, witnesses: %w[C]),
                build(:token_grouped_variant, :insignificant, witnesses: %w[D])
              ])
      end

      it 'copies the selected grouped variant from the source token' do
        grouped_variant = find_grouped_variant(grouped_variants: target_token.grouped_variants, witnesses: %w[B A])
        expect(grouped_variant).to be_selected
      end

      it 'copies the possible grouped variant from the source token' do
        grouped_variant = find_grouped_variant(grouped_variants: target_token.grouped_variants, witnesses: ['C'])
        expect(grouped_variant).to be_possible
      end

      it 'does not change the insignificant grouped variant' do
        grouped_variant = find_grouped_variant(grouped_variants: target_token.grouped_variants, witnesses: ['D'])
        expect(grouped_variant).to be_insignificant
      end
    end
  end
end
