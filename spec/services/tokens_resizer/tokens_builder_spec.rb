# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensResizer::TokensBuilder, type: :service do
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

      it 'merges tokens into one' do
        expect(result.size).to eq(1)
      end

      it 'uses the whole text as token\'s :t' do
        token = result.first
        expect(token.t).to eq(selected_text)
      end

      it 'preserves the variants of the multiple grouped variants token' do
        token = result.first
        token.variants.each do |variant|
          matching_prev_variant = find_variant(variants: prev_token2.variants, witness: variant.witness)
          expect(variant.t).to eq("#{expected_prefix}#{matching_prev_variant.t}#{expected_suffix}")
        end
      end

      it 'calculates the grouped variants using the GroupedVariantsGenerator' do
        token = result.first
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end
    end

    context 'when the text was selected from the beginning' do
      let(:prev_token) { create(:token, project:) }
      let(:prev_token2) { create(:token, :one_grouped_variant, project:) }
      let(:selected_text) { "#{prev_token.t}#{prev_token2.t[0...1]}" }
      let(:expected_suffix) { prev_token2.t[0...1].to_s }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the selected_text for the first token\'s :t' do
        token = result.first
        expect(token.t).to eq(selected_text)
      end

      it 'uses the part after the selected_text for the second token\'s :t' do
        token = result.second
        expect(token.t).to eq(prev_token2.t[1...])
      end

      it 'preserves the variants of the multiple grouped variants token' do
        token = result.first
        token.variants.each do |variant|
          matching_prev_variant = find_variant(variants: prev_token.variants, witness: variant.witness)
          expect(variant.t).to eq("#{matching_prev_variant.t}#{expected_suffix}")
        end
      end

      it 'calculates the grouped variants of the first token with GroupedVariantsGenerator' do
        token = result.first
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end

      it 'calculates the grouped variants of the second token with GroupedVariantsGenerator' do
        token = result.last
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end
    end

    context 'when the text was selected from the middle' do
      let(:prev_token) { create(:token, :one_grouped_variant, project:) }
      let(:prev_token2) { create(:token, :one_grouped_variant, project:) }
      let(:selected_text) { "#{prev_token.t[1...]}#{prev_token2.t[0...1]}" }

      it 'creates three tokens' do
        expect(result.size).to eq(3)
      end

      it 'uses the part before the selected_text for the first token\'s :t' do
        token = result.first
        expect(token.t).to eq(prev_token.t[0...1])
      end

      it 'uses the part before the selected_text for all variants of the first token\'s :t' do
        token = result.first
        token.variants.each do |variant|
          expect(variant.t).to eq(prev_token.t[0...1])
        end
      end

      it 'uses the selected_text for the seconds token\'s :t' do
        token = result.second
        expect(token.t).to eq(selected_text)
      end

      it 'uses the selected_text for all variants of the first token\'s :t' do
        token = result.second
        token.variants.each do |variant|
          expect(variant.t).to eq(selected_text)
        end
      end

      it 'uses the part after the selected_text for the third token\'s :t' do
        token = result.last
        expect(token.t).to eq(prev_token2.t[1...])
      end

      it 'uses the part after the selected_text for all variants of the last token\'s :t' do
        token = result.last
        token.variants.each do |variant|
          expect(variant.t).to eq(prev_token2.t[1...])
        end
      end

      it 'calculates the grouped variants of the first token with GroupedVariantsGenerator' do
        token = result.first
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end

      it 'calculates the grouped variants of the second token with GroupedVariantsGenerator' do
        token = result.second
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end

      it 'calculates the grouped variants of third token with GroupedVariantsGenerator' do
        token = result.last
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end
    end

    context 'when the text was selected from the middle to the end' do
      let(:prev_token) { create(:token, :one_grouped_variant, project:) }
      let(:prev_token2) { create(:token, project:) }
      let(:selected_text) { "#{prev_token.t[1...]}#{prev_token2.t}" }
      let(:expected_prefix) { prev_token.t[1...] }

      it 'creates two tokens' do
        expect(result.size).to eq(2)
      end

      it 'uses the part before the selected_text for the first token' do
        token = result.first
        expect(token.t).to eq(prev_token.t[0...1])
      end

      it 'uses the selected_text for the second token\'s :t' do
        token = result.second
        expect(token.t).to eq(selected_text)
      end

      it 'preserves the variants of the multiple grouped variants token token' do
        token = result.second
        token.variants.each do |variant|
          matching_prev_variant = find_variant(variants: prev_token2.variants, witness: variant.witness)
          expect(variant.t).to eq("#{expected_prefix}#{matching_prev_variant.t}")
        end
      end

      it 'calculates the grouped variants of the first token with GroupedVariantsGenerator' do
        token = result.first
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end

      it 'calculates the grouped variants of the second token with GroupedVariantsGenerator' do
        token = result.last
        expect(token.grouped_variants).to eq(TokensManager::GroupedVariantsGenerator.perform(token:))
      end
    end
  end
end
