# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Preparers::TokenFromMultipleTokens, type: :service do
  let(:project) { create(:project) }
  let(:params) do
    TokensManager::Resizer::Params.new(
      selected_token_ids:,
      project:
    )
  end

  describe '#perform' do
    let(:token) { described_class.new(params:).perform }

    before do
      create(:comment, token: selected_token1, body: 'test comment')
    end

    context 'when all selected tokens have text' do
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }
      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, project:, index: 1) }
      let(:selected_token3) { create(:token, project:, index: 2) }

      # rubocop:disable RSpec/ExampleLength
      it 'prepares variants values by merging values of variants from the selected tokens' do
        token.variants.each do |variant|
          expected_value = ''
          [selected_token1, selected_token2, selected_token3].each do |selected_token|
            selected_variant = find_variant(variants: selected_token.variants, witness: variant.witness)
            expected_value += selected_variant.t.to_s
          end
          expect(variant.t).to eq(expected_value)
        end
      end
      # rubocop:enable RSpec/ExampleLength

      it 'generates grouped variants' do
        expected_grouped_variants = TokensManager::GroupedVariantsGenerator.perform(token:)
        expect(token.grouped_variants).to eq(expected_grouped_variants)
      end

      it 'does not have any value selected' do
        expect(token.selected_variant).to be_nil
      end

      it 'does not have any editorial remark' do
        expect(token.editorial_remark).to be_nil
      end

      it 'does not have comments' do
        expect(token.comments).to be_empty
      end

      it 'sets resized to true' do
        expect(token).to be_resized
      end
    end

    context 'when all of the selected tokens have empty values' do
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }
      let(:selected_token1) { create(:token, project:, index: 0, with_empty_values: true) }
      let(:selected_token2) { create(:token, project:, index: 1, with_empty_values: true) }
      let(:selected_token3) { create(:token, project:, index: 2, with_empty_values: true) }

      it 'prepares variants with nil values' do
        token.variants.each do |variant|
          expect(variant.t).to be_nil
        end
      end

      it 'generates grouped variants' do
        expected_grouped_variants = TokensManager::GroupedVariantsGenerator.perform(token:)
        expect(token.grouped_variants).to eq(expected_grouped_variants)
      end

      it 'does not have any value selected' do
        expect(token.selected_variant).to be_nil
      end

      it 'does not have any editorial remark' do
        expect(token.editorial_remark).to be_nil
      end

      it 'does not have comments' do
        expect(token.comments).to be_empty
      end

      it 'sets resized to true' do
        expect(token).to be_resized
      end
    end

    context 'when one of the selected tokens have empty values' do
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id, selected_token3.id] }
      let(:selected_token1) { create(:token, project:, index: 0) }
      let(:selected_token2) { create(:token, project:, index: 1, with_empty_values: true) }
      let(:selected_token3) { create(:token, project:, index: 2) }

      # rubocop:disable RSpec/ExampleLength
      it 'prepares variants values by ignoring the empty ones' do
        token.variants.each do |variant|
          expected_value = ''
          [selected_token1, selected_token3].each do |selected_token|
            selected_variant = find_variant(variants: selected_token.variants, witness: variant.witness)
            expected_value += selected_variant.t.to_s
          end
          expect(variant.t).to eq(expected_value)
        end
      end
      # rubocop:enable RSpec/ExampleLength

      it 'generates grouped variants' do
        expected_grouped_variants = TokensManager::GroupedVariantsGenerator.perform(token:)
        expect(token.grouped_variants).to eq(expected_grouped_variants)
      end

      it 'does not have any value selected' do
        expect(token.selected_variant).to be_nil
      end

      it 'does not have any editorial remark' do
        expect(token.editorial_remark).to be_nil
      end

      it 'does not have comments' do
        expect(token.comments).to be_empty
      end

      it 'sets resized to true' do
        expect(token).to be_resized
      end
    end
  end
end
