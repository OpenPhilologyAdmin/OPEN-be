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
    described_class.new(project:, user:, selected_text:, selected_token_ids:)
  end

  describe '#perform' do
    context 'when there are no tokens with multiple readings in the selection' do
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

      it 'removes the redundant selected token' do
        expect(Token.where(id: selected_token.id)).to be_empty
      end

      it 'creates a correct number of new tokens' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end

      it 'ensures the tokens\' indexes are correct' do
        expected_indexes = 0.upto(expected_nr_of_tokens - 1)
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'saves the substring before the selected_text as a first token' do
        expect(project.tokens.first.t).to eq(selected_token.t[0...1])
      end

      it 'saves the selected_text as second token' do
        expect(project.tokens.second.t).to eq(selected_text)
      end

      it 'saves the substring after the selected_text as a third token' do
        expect(project.tokens.third.t).to eq(selected_token.t[-1...])
      end
    end

    context 'when there is a token with multiple readings in the selection' do
      let(:selected_token) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, :variant_selected, project:, index: 1) }
      let(:substring_before) { selected_token.t[1...].to_s }
      let(:selected_text) { "#{substring_before}#{selected_token2.t}" }
      let(:selected_token_ids) { [selected_token.id, selected_token2.id] }
      let(:expected_nr_of_tokens) { 6 }
      let(:updated_token) { project.tokens.second }

      before do
        2.upto(5) { |index| create(:token, project:, index:) }
        service.perform
        project.reload
      end

      it 'saves the user as the last editor of the project' do
        expect(project.last_editor).to eq(user)
      end

      it 'removes the redundant selected token' do
        expect(Token.where(id: selected_token.id)).not_to be_any
      end

      it 'does not remove the selected token with multiple readings because it is still in use' do
        expect(Token.where(id: selected_token2.id)).to be_any
      end

      it 'creates a correct number of new tokens' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end

      it 'ensures the tokens\' indexes are correct' do
        expected_indexes = 0.upto(expected_nr_of_tokens - 1)
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'saves the substring_before the selected_text as a first token' do
        expect(project.tokens.first.t).to eq(selected_token.t[0...1])
      end

      it 'adds new text to the variants of the token that have multiple readings' do
        updated_token.variants.each do |variant|
          matching_variant = find_variant(variants: selected_token2.variants, witness: variant.witness)
          expect(variant.t).to eq("#{substring_before}#{matching_variant.t}")
        end
      end

      it 'adds new text to the grouped variants of the token that have multiple readings' do
        updated_token.grouped_variants.each do |variant|
          matching_grouped_variant = find_grouped_variant(grouped_variants: selected_token2.grouped_variants,
                                                          witnesses:        variant.witnesses)
          expect(variant.t).to eq("#{substring_before}#{matching_grouped_variant.t}")
        end
      end

      it 'adds new text to the editorial remark of the token that have multiple readings' do
        expect(updated_token.editorial_remark.t).to eq("#{substring_before}#{selected_token2.editorial_remark.t}")
      end

      it 'preserves selections of the token that have multiple readings' do
        expect(updated_token.grouped_variants.select(&:significant?)).not_to be_empty
      end
    end
  end
end
