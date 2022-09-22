# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe TokensManager::Resizer::Preparers::TokenFromMultipleReadingsToken, type: :service do
  let(:project) { create(:project) }
  let(:params) do
    TokensManager::Resizer::Params.new(
      selected_text:,
      selected_token_ids:,
      project:,
      tokens_with_offsets:
    )
  end

  describe '#perform' do
    let(:token) { described_class.new(params:, value_before_selected_text:).perform }

    context 'when there are no possible/selected variants in the source multiple readings token' do
      let(:value_before_selected_text) { selected_token1.t[0] }
      let(:value_before_token) { selected_token1.t[1..] }
      let(:value_after_token) { selected_token3.t }
      let(:selected_text) { "#{value_before_token}#{selected_multiple_readings_token.t}#{value_after_token}" }
      let(:selected_token_ids) { [selected_token1.id, selected_multiple_readings_token.id, selected_token3.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   1,
            token_id: selected_token1.id
          },
          {
            offset:   selected_token3.t.size,
            token_id: selected_token3.id
          }
        ]
      end
      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_multiple_readings_token) { create(:token, project:, index: 1) }
      let(:selected_token3) { create(:token, :one_grouped_variant, project:, index: 2) }

      it 'uses the whole selected text as the token\'s :t' do
        expect(token.t).to eq(selected_text)
      end

      it 'adds before & after values to the variants of the selected token that had multiple readings' do
        token.variants.each do |variant|
          matching_variant = find_variant(variants: selected_multiple_readings_token.variants, witness: variant.witness)
          expect(variant.t).to eq("#{value_before_token}#{matching_variant.t}#{value_after_token}")
        end
      end

      it 'adds before & after values to the grouped variants of the token that have multiple readings' do
        token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(
            grouped_variants: selected_multiple_readings_token.grouped_variants,
            witnesses:        variant.witnesses
          )
          expect(variant.t).to eq("#{value_before_token}#{matching_grouped_variant.t}#{value_after_token}")
        end
      end

      it 'preserves possible & selected of the token that have multiple readings' do
        token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(
            grouped_variants: selected_multiple_readings_token.grouped_variants,
            witnesses:        variant.witnesses
          )
          expect(variant.selected).to eq(matching_grouped_variant.selected)
          expect(variant.possible).to eq(matching_grouped_variant.possible)
        end
      end

      it 'adds before & after values to the editorial remark of the token that have multiple readings' do
        expect(token.editorial_remark.t).to eq(
          "#{value_before_token}#{selected_multiple_readings_token.editorial_remark.t}#{value_after_token}"
        )
      end
    end

    context 'when there are some possible/selected variants in the source multiple readings token' do
      let(:value_before_selected_text) { '' }
      let(:value_before_token) { selected_token1.t }
      let(:value_after_token) { selected_token3.t[..-2] }
      let(:selected_text) { "#{value_before_token}#{selected_multiple_readings_token.t}#{value_after_token}" }
      let(:selected_token_ids) { [selected_token1.id, selected_multiple_readings_token.id, selected_token3.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   0,
            token_id: selected_token1.id
          },
          {
            offset:   selected_token3.t.size - 2,
            token_id: selected_token3.id
          }
        ]
      end
      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_multiple_readings_token) { create(:token, :variant_selected_and_secondary, project:, index: 1) }
      let(:selected_token3) { create(:token, :one_grouped_variant, project:, index: 2) }

      it 'uses the whole selected text as the token\'s :t' do
        expect(token.t).to eq(selected_text)
      end

      it 'adds before & after values to the variants of the selected token that had multiple readings' do
        token.variants.each do |variant|
          matching_variant = find_variant(variants: selected_multiple_readings_token.variants, witness: variant.witness)
          expect(variant.t).to eq("#{value_before_token}#{matching_variant.t}#{value_after_token}")
        end
      end

      it 'adds before & after values to the grouped variants of the token that have multiple readings' do
        token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(
            grouped_variants: selected_multiple_readings_token.grouped_variants,
            witnesses:        variant.witnesses
          )
          expect(variant.t).to eq("#{value_before_token}#{matching_grouped_variant.t}#{value_after_token}")
        end
      end

      it 'preserves possible & selected of the token that have multiple readings' do
        token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(
            grouped_variants: selected_multiple_readings_token.grouped_variants,
            witnesses:        variant.witnesses
          )
          expect(variant.selected).to eq(matching_grouped_variant.selected)
          expect(variant.possible).to eq(matching_grouped_variant.possible)
        end
      end

      it 'adds before & after values to the editorial remark of the token that have multiple readings' do
        expect(token.editorial_remark.t).to eq(
          "#{value_before_token}#{selected_multiple_readings_token.editorial_remark.t}#{value_after_token}"
        )
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
