# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer, type: :service do
  let(:project) { create(:project) }
  let(:user) { create(:user, :approved, :admin) }

  let(:service) do
    described_class.new(project:, user:, selected_text:, selected_token_ids:, tokens_with_offsets:)
  end

  describe '#perform' do
    context 'when there are is no token with multiple readings in the selected_token_ids' do
      let(:tokens_with_offsets) do
        [
          {
            offset:   1,
            token_id: selected_token.id
          },
          {
            offset:   selected_token.t.size - 1,
            token_id: selected_token.id
          }
        ]
      end
      let(:selected_token) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_text) { selected_token.t[1...-1].to_s }
      let(:selected_token_ids) { [selected_token.id] }
      let(:expected_nr_of_tokens) { 8 }

      before do
        1.upto(5) { |index| create(:token, project:, index:) }
        service.perform
        project.reload
      end

      it 'saves the user as the last editor of the project' do
        expect(project.last_editor).to eq(user)
      end

      it 'removes the selected tokens' do
        removed_tokens_ids = [selected_token.id]
        expect(Token.where(id: removed_tokens_ids)).to be_empty
      end

      it 'creates a correct number of new tokens' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end

      it 'ensures the tokens\' indexes are correct' do
        expected_indexes = 0.upto(expected_nr_of_tokens - 1)
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'saves the value before the selected_text as a first token' do
        token = project.tokens.first
        value_before_selected_text = selected_token.t[0]
        expect(token.t).to eq(value_before_selected_text)
      end

      it 'saves the selected_text as second token' do
        token = project.tokens.second
        expect(token.t).to eq(selected_text)
      end

      it 'saves the value after the selected_text as a third token' do
        token = project.tokens.third
        value_aster_selected_text = selected_token.t[-1..]
        expect(token.t).to eq(value_aster_selected_text)
      end
    end

    context 'when there is a token with multiple readings in the selected_token_ids' do
      let(:tokens_with_offsets) do
        [
          {
            offset:   1,
            token_id: selected_token.id
          },
          {
            offset:   selected_token2.t.size,
            token_id: selected_token2.id
          }
        ]
      end
      let(:selected_token) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, :variant_selected, project:, index: 1) }
      let(:selected_text_value_before_token) { selected_token.t[1..].to_s }
      let(:selected_text) { "#{selected_text_value_before_token}#{selected_token2.t}" }
      let(:selected_token_ids) { [selected_token.id, selected_token2.id] }
      let(:expected_nr_of_tokens) { 6 }

      before do
        2.upto(5) { |index| create(:token, project:, index:) }
        service.perform
        project.reload
      end

      it 'saves the user as the last editor of the project' do
        expect(project.last_editor).to eq(user)
      end

      it 'removes all selected tokens' do
        removed_tokens_ids = [selected_token.id, selected_token2.id]
        expect(Token.where(id: removed_tokens_ids)).to be_empty
      end

      it 'creates a correct number of new tokens' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end

      it 'ensures the tokens\' indexes are correct' do
        expected_indexes = 0.upto(expected_nr_of_tokens - 1)
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'saves the value before selected_text the selected_text as a first token' do
        token = project.tokens.first
        value_before_selected_text = selected_token.t[0]
        expect(token.t).to eq(value_before_selected_text)
      end

      it 'adds before value to the variants of the token that have multiple readings' do
        token = project.tokens.second
        token.variants.each do |variant|
          matching_variant = find_variant(variants: selected_token2.variants, witness: variant.witness)
          expect(variant.t).to eq("#{selected_text_value_before_token}#{matching_variant.t}")
        end
      end

      it 'adds before value to the grouped variants of the token that have multiple readings' do
        token = project.tokens.second
        token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(
            grouped_variants: selected_token2.grouped_variants,
            witnesses:        variant.witnesses
          )
          expect(variant.t).to eq("#{selected_text_value_before_token}#{matching_grouped_variant.t}")
        end
      end

      it 'adds before value to the editorial remark of the token that have multiple readings' do
        token = project.tokens.second
        expected_value = "#{selected_text_value_before_token}#{selected_token2.editorial_remark.t}"
        expect(token.editorial_remark.t).to eq(expected_value)
      end

      it 'preserves selections of the token that have multiple readings' do
        token = project.tokens.second
        expect(token.grouped_variants.select(&:significant?)).not_to be_empty
      end
    end
  end
end
