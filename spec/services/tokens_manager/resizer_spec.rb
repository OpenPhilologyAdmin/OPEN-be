# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer, type: :service do
  let(:project) { create(:project) }
  let(:user) { create(:user, :approved, :admin) }
  let(:params) do
    {
      selected_text:,
      selected_token_ids:,
      tokens_with_offsets:
    }
  end
  let(:result) { service.perform }

  let(:service) do
    described_class.new(project:, user:, params:)
  end

  describe '#perform' do
    context 'when given params are invalid' do
      let(:selected_text) { '' }
      let(:selected_token_ids) { [] }
      let(:tokens_with_offsets) { [] }

      before do
        allow(TokensManager::Resizer::Preparer).to receive(:perform)
        allow(TokensManager::Resizer::Processor).to receive(:perform)
        result
      end

      it 'returns result with success: false' do
        expect(result).not_to be_success
      end

      it 'returns result with params that have errors' do
        expect(result.params).not_to be_valid
      end

      it 'does not run TokensManager::Resizer::Preparer' do
        expect(TokensManager::Resizer::Preparer).not_to have_received(:perform)
      end

      it 'does not run TokensManager::Resizer::Processor' do
        expect(TokensManager::Resizer::Processor).not_to have_received(:perform)
      end

      it 'does not update last editor of the project' do
        expect(project.reload.last_editor).to be_nil
      end
    end

    context 'when given params are valid' do
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
          result
          project.reload
        end

        it 'saves the user as the last editor of the project' do
          expect(project.last_editor).to eq(user)
        end

        it 'saves project as the last edited project by user' do
          expect(user.last_edited_project).to eq(project)
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

        it 'leaves resized as false on the first token' do
          token = project.tokens.first
          expect(token).not_to be_resized
        end

        it 'saves the selected_text as second token' do
          token = project.tokens.second
          expect(token.t).to eq(selected_text)
        end

        it 'sets resized as true on the second token' do
          token = project.tokens.second
          expect(token).to be_resized
        end

        it 'saves the value after the selected_text as a third token' do
          token = project.tokens.third
          value_aster_selected_text = selected_token.t[-1..]
          expect(token.t).to eq(value_aster_selected_text)
        end

        it 'returns result with success: true' do
          expect(result).to be_success
        end

        it 'returns result with params that does not have any errors' do
          expect(result.params).to be_valid
        end
      end

      # rubocop:disable RSpec/MultipleMemoizedHelpers
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

        before do
          2.upto(5) { |index| create(:token, project:, index:) }
          result
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
          expected_nr_of_tokens = 6
          expect(project.tokens.size).to eq(expected_nr_of_tokens)
        end

        it 'ensures the tokens\' indexes are correct' do
          expected_indexes = 0.upto(5)
          expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
        end

        it 'saves the value before selected_text the selected_text as a first token' do
          token = project.tokens.first
          value_before_selected_text = selected_token.t[0]
          expect(token.t).to eq(value_before_selected_text)
        end

        it 'leaves resized as false on the first token' do
          token = project.tokens.first
          expect(token).not_to be_resized
        end

        it 'uses the selected_text for the token that have multiple readings' do
          token = project.tokens.second
          expect(token.t).to eq(selected_text)
        end

        it 'sets resized as true on the token that have multiple readings' do
          token = project.tokens.second
          expect(token).to be_resized
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

        it 'returns result with success: true' do
          expect(result).to be_success
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
