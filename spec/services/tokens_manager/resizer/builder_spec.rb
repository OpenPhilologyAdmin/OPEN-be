# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Builder, type: :service do
  let(:project) { create(:project) }
  let(:service) do
    described_class.new(
      selected_text:,
      selected_tokens: [prev_token, prev_token2],
      project:
    )
  end
  let(:result) { service.perform }

  describe '#perform' do
    context 'when the whole text from all tokens has been selected' do
      let(:service) do
        described_class.new(
          selected_text:,
          selected_tokens: [prev_token, prev_token2, prev_token3],
          project:
        )
      end
      let(:prev_token) { create(:token, :one_grouped_variant, project:) }
      let(:prev_token2) { create(:token, project:) }
      let(:prev_token3) { create(:token, :one_grouped_variant, project:) }
      let(:selected_text) { "#{prev_token.t}#{prev_token2.t}#{prev_token3.t}" }
      let(:expected_prefix) { prev_token.t }
      let(:expected_suffix) { prev_token3.t }
      let(:selected_text_token) { result.first }

      it 'merges tokens into one' do
        expect(result.size).to eq(1)
      end

      it 'uses the whole text as token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'applies substrings on the variants of the multiple grouped variants token' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to start_with(expected_prefix)
          expect(variant.t).to end_with(expected_suffix)
        end
      end

      it 'calculates the grouped variants using the GroupedVariantsGenerator' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end
    end

    context 'when the text was selected from the beginning' do
      let(:prev_token) { create(:token, :variant_selected_and_secondary, project:) }
      let(:prev_token2) { create(:token, :one_grouped_variant, project:) }
      let(:selected_text) { "#{prev_token.t}#{prev_token2.t[0...1]}" }
      let(:expected_suffix) { prev_token2.t[0...1].to_s }
      let(:selected_text_token) { result.first }
      let(:suffix_token) { result.second }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the selected_text for the first token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'uses the part after the selected_text for the second token\'s :t' do
        expect(suffix_token.t).to eq(prev_token2.t[1...])
      end

      it 'applies substring_after on the variants of the multiple grouped variants token' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to end_with(expected_suffix)
        end
      end

      it 'calculates the grouped variants and preserves selections from the source token' do
        selected_text_token.grouped_variants.each do |target_grouped_variant|
          source_grouped_variant = find_grouped_variant(
            grouped_variants: prev_token.grouped_variants,
            witnesses:        target_grouped_variant.witnesses
          )
          expect(target_grouped_variant.possible).to eq(source_grouped_variant.possible)
          expect(target_grouped_variant.selected).to eq(source_grouped_variant.selected)
        end
      end

      it 'applies substring_after on the editorial_remark of the multiple grouped variants token' do
        expect(selected_text_token.editorial_remark.t).to end_with(expected_suffix)
      end

      it 'calculates the correct grouped variants of the second token' do
        expect(suffix_token.grouped_variants).to eq(generate_grouped_variants(token: suffix_token))
      end
    end

    context 'when the text was selected from the middle' do
      let(:prev_token) { create(:token, :one_grouped_variant, project:) }
      let(:prev_token2) { create(:token, :one_grouped_variant, project:) }
      let(:selected_text) { "#{prev_token.t[1...]}#{prev_token2.t[0...1]}" }
      let(:prefix_token) { result.first }
      let(:selected_text_token) { result.second }
      let(:suffix_token) { result.last }

      it 'creates three tokens' do
        expect(result.size).to eq(3)
      end

      it 'uses the part before the selected_text for the first token\'s :t' do
        expect(prefix_token.t).to eq(prev_token.t[0...1])
      end

      it 'uses the part before the selected_text for all variants of the first token\'s :t' do
        prefix_token.variants.each do |variant|
          expect(variant.t).to eq(prev_token.t[0...1])
        end
      end

      it 'uses the selected_text for the second token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'uses the selected_text for all variants of the first token\'s :t' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to eq(selected_text)
        end
      end

      it 'uses the part after the selected_text for the third token\'s :t' do
        expect(suffix_token.t).to eq(prev_token2.t[1...])
      end

      it 'uses the part after the selected_text for all variants of the last token\'s :t' do
        suffix_token.variants.each do |variant|
          expect(variant.t).to eq(prev_token2.t[1...])
        end
      end

      it 'calculates the correct grouped variants of the first token' do
        expect(prefix_token.grouped_variants).to eq(generate_grouped_variants(token: prefix_token))
      end

      it 'calculates the correct grouped variants of the second token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of third token' do
        expect(suffix_token.grouped_variants).to eq(generate_grouped_variants(token: suffix_token))
      end
    end

    context 'when the text was selected from the middle to the end' do
      let(:prev_token) { create(:token, :one_grouped_variant, project:) }
      let(:prev_token2) { create(:token, project:) }
      let(:selected_text) { "#{prev_token.t[1...]}#{prev_token2.t}" }
      let(:expected_prefix) { prev_token.t[1...] }
      let(:prefix_token) { result.first }
      let(:selected_text_token) { result.second }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the part before the selected_text for the first token' do
        expect(prefix_token.t).to eq(prev_token.t[0...1])
      end

      it 'uses the selected_text for the second token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text)
      end

      it 'applies substring_before on the variants of the multiple grouped variants token' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to start_with(expected_prefix)
        end
      end

      it 'calculates the correct grouped variants of the first token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of the second token' do
        expect(prefix_token.grouped_variants).to eq(generate_grouped_variants(token: prefix_token))
      end
    end

    context 'when the text includes EMPTY_VALUE_PLACEHOLDER' do
      let(:prev_token) { create(:token, project:) }
      let(:prev_token2) { create(:token, :one_grouped_variant, project:, with_empty_values: true) }
      let(:prev_token3) { create(:token, :one_grouped_variant, project:) }

      let(:service) do
        described_class.new(
          selected_text:,
          selected_tokens: [prev_token, prev_token2, prev_token3],
          project:
        )
      end

      let(:selected_text) { "#{prev_token.t}#{prev_token2.t}#{prev_token3.t[0...2]}" }
      let(:expected_suffix) { prev_token3.t[0...2].to_s }
      let(:selected_text_token) { result.first }
      let(:suffix_token) { result.second }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the selected_text without EMPTY_VALUE_PLACEHOLDER for the first token\'s :t' do
        expect(selected_text_token.t).to eq(selected_text.tr(FormattableT::EMPTY_VALUE_PLACEHOLDER, ''))
      end

      it 'uses the part after the selected_text for the second token\'s :t' do
        expect(suffix_token.t).to eq(prev_token3.t[2...])
      end

      it 'applies substring+_after on the variants of the multiple grouped variants token' do
        selected_text_token.variants.each do |variant|
          expect(variant.t).to end_with(expected_suffix)
        end
      end

      it 'calculates the correct grouped variants of the first token' do
        expect(selected_text_token.grouped_variants).to eq(generate_grouped_variants(token: selected_text_token))
      end

      it 'calculates the correct grouped variants of the second token' do
        expect(suffix_token.grouped_variants).to eq(generate_grouped_variants(token: suffix_token))
      end
    end
  end
end
