# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Preparer, type: :service do
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
    let(:result) { described_class.new(params:).perform }

    context 'when the whole text from all tokens has been selected' do
      let(:selected_text) { "#{selected_token1.t}#{selected_token2.t}#{selected_token3.t}" }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   0,
            token_id: selected_token1.id
          },
          {
            offset:   selected_token3.t.size,
            token_id: selected_token3.id
          }
        ]
      end

      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, project:, index: 1) }
      let(:selected_token3) { create(:token, :one_grouped_variant, project:, index: 2) }

      let(:selected_text_token) { result.first }

      it 'merges tokens into one' do
        expect(result.size).to eq(1)
      end

      it 'uses the whole selected text as the selected text token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'sets resized to true on the selected text token' do
        expect(selected_text_token).to be_resized
      end

      it 'adds the beginning of the selected text to the variants of the selected text token' do
        value_before_token = selected_token1.t
        selected_text_token.variants.each do |variant|
          expect(variant.t).to start_with(value_before_token)
        end
      end

      it 'adds the end of the selected text to the variants of the selected text token' do
        value_after_token = selected_token3.t
        selected_text_token.variants.each do |variant|
          expect(variant.t).to end_with(value_after_token)
        end
      end

      it 'calculates the grouped variants of the selected text token using the GroupedVariantsGenerator' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end
    end

    context 'when the text was selected from the beginning of first token' do
      let(:selected_text) { "#{selected_token1.t}#{selected_token2.t[0]}" }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   0,
            token_id: selected_token1.id
          },
          {
            offset:   1,
            token_id: selected_token2.id
          }
        ]
      end
      let(:selected_token1) { create(:token, :variant_selected_and_secondary, project:, index: 0) }
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }

      let(:selected_text_token) { result.first }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the selected_text for the first token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'sets resized to true on the selected text token' do
        expect(selected_text_token).to be_resized
      end

      it 'adds the end of the selected_text to the variants of the selected text token' do
        value_after_token = selected_token2.t[0]
        selected_text_token.variants.each do |variant|
          expect(variant.t).to end_with(value_after_token)
        end
      end

      it 'copies the grouped variants and preserves selections from the selected multiple readings token' do
        selected_text_token.grouped_variants.each do |target_grouped_variant|
          source_grouped_variant = find_grouped_variant(
            grouped_variants: selected_token1.grouped_variants,
            witnesses:        target_grouped_variant.witnesses
          )
          expect(target_grouped_variant.possible).to eq(source_grouped_variant.possible)
          expect(target_grouped_variant.selected).to eq(source_grouped_variant.selected)
        end
      end

      it 'adds the end of the selected_text to the editorial_remark of the selected text token' do
        value_after_token = selected_token2.t[0]
        expect(selected_text_token.editorial_remark.t).to end_with(value_after_token)
      end

      it 'uses the part after the selected_text for the second token\'s :t' do
        token = result.second
        value_after_selected_text = selected_token2.t[1..]
        expect(token.t).to eq(value_after_selected_text)
      end

      it 'leaves resized as false on the second token' do
        token = result.second
        expect(token).not_to be_resized
      end

      it 'calculates the correct grouped variants for the the second token' do
        token = result.second
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end

    context 'when the text was selected from and to the middle of tokens' do
      let(:selected_text) { "#{selected_token1.t[1..]}#{selected_token2.t[0]}" }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   1,
            token_id: selected_token1.id
          },
          {
            offset:   1,
            token_id: selected_token2.id
          }
        ]
      end

      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }
      let(:selected_text_token) { result.second }

      it 'creates three tokens' do
        expect(result.size).to eq(3)
      end

      it 'uses the value before the selected_text for the first token\'s :t' do
        token = result.first
        value_before_selected_text = selected_token1.t[0]
        expect(token.t).to eq(value_before_selected_text)
      end

      it 'leaves resized as false on the first token' do
        token = result.first
        expect(token).not_to be_resized
      end

      it 'uses the value before the selected_text for all variants of the first token\'s :t' do
        token = result.first
        value_before_selected_text = selected_token1.t[0]
        token.variants.each do |variant|
          expect(variant.t).to eq(value_before_selected_text)
        end
      end

      it 'uses the selected_text for the second token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'sets resized to true on the selected text token' do
        expect(selected_text_token).to be_resized
      end

      it 'uses the selected_text for all variants of the first token\'s :t' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to eq(selected_text)
        end
      end

      it 'uses the value after the selected_text for the third token\'s :t' do
        token = result.last
        value_after_selected_text = selected_token2.t[1..]
        expect(token.t).to eq(value_after_selected_text)
      end

      it 'leaves resized as false on the third token' do
        token = result.last
        expect(token).not_to be_resized
      end

      it 'uses the value after the selected_text for all variants of the last token\'s :t' do
        token = result.last
        value_after_selected_text = selected_token2.t[1..]
        token.variants.each do |variant|
          expect(variant.t).to eq(value_after_selected_text)
        end
      end

      it 'calculates the correct grouped variants of the first token' do
        token = result.first
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end

      it 'calculates the correct grouped variants of the selected text token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of third token' do
        token = result.last
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end

    context 'when the text was selected from the middle of the first token to the end of last token' do
      let(:selected_text) { "#{selected_token1.t[1..]}#{selected_token2.t}" }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   1,
            token_id: selected_token1.id
          },
          {
            offset:   selected_token2.t.size,
            token_id: selected_token2.id
          }
        ]
      end

      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, project:, index: 1) }
      let(:selected_text_token) { result.second }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the value before the selected_text for the first token' do
        token = result.first
        value_before_selected_text = selected_token1.t[0]
        expect(token.t).to eq(value_before_selected_text)
      end

      it 'leaves resized as false on the first token' do
        token = result.first
        expect(token).not_to be_resized
      end

      it 'uses the selected_text for the second token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'sets resized to true on the selected text token' do
        expect(selected_text_token).to be_resized
      end

      it 'adds the beginning of the selected text to the variants of the selected text token' do
        value_before_token = selected_token1.t[1..]
        selected_text_token.variants.each do |variant|
          expect(variant.t).to start_with(value_before_token)
        end
      end

      it 'calculates the correct grouped variants of the selected text token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of the second token' do
        token = result.first
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end

    context 'when the selected text includes EMPTY_VALUE_PLACEHOLDERs' do
      let(:selected_text) { "#{selected_token1.t}#{selected_token2.t}#{selected_token3.t[0..1]}" }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }
      let(:tokens_with_offsets) do
        [
          {
            offset:   0,
            token_id: selected_token1.id
          },
          {
            offset:   2,
            token_id: selected_token3.id
          }
        ]
      end

      let(:selected_token1) { create(:token, project:, index: 0) }
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, with_empty_values: true, index: 1) }
      let(:selected_token3) { create(:token, :one_grouped_variant, project:, index: 2) }

      let(:selected_text_token) { result.first }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the selected_text without EMPTY_VALUE_PLACEHOLDER for the first token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text.tr(FormattableT::EMPTY_VALUE_PLACEHOLDER, ''))
      end

      it 'sets resized to true on the selected text token' do
        expect(selected_text_token).to be_resized
      end

      it 'uses the value after the selected_text for the second token\'s :t' do
        token = result.second
        value_before_selected_text = selected_token3.t[2..]
        expect(token.t).to eq(value_before_selected_text)
      end

      it 'leaves resized as false on the second token' do
        token = result.second
        expect(token).not_to be_resized
      end

      it 'adds the end of the selected_text to the variants of the selected text token' do
        value_after_token = selected_token3.t[0...2]
        selected_text_token.variants.each do |variant|
          expect(variant.t).to end_with(value_after_token)
        end
      end

      it 'calculates the correct grouped variants of the selected text token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of the second token' do
        token = result.second
        expect(token.grouped_variants).to eq(generate_grouped_variants(token:))
      end
    end
  end
end
