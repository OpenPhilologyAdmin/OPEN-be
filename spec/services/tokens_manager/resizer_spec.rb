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
      selected_token_ids:
    }
  end
  let(:result) { service.perform }

  let(:service) do
    described_class.new(project:, user:, params:)
  end

  describe '#perform' do
    context 'when given params are invalid' do
      let(:selected_token_ids) { [] }

      before do
        allow(TokensManager::Resizer::Preparers::TokenFromMultipleTokens).to receive(:perform)
        allow(TokensManager::Resizer::Processor).to receive(:perform)
        result
      end

      it 'returns result with success: false' do
        expect(result).not_to be_success
      end

      it 'returns result with params that have errors' do
        expect(result.params).not_to be_valid
      end

      it 'does not run TokensManager::Resizer::Preparers::TokenFromMultipleTokens' do
        expect(TokensManager::Resizer::Preparers::TokenFromMultipleTokens).not_to have_received(:perform)
      end

      it 'does not run TokensManager::Resizer::Processor' do
        expect(TokensManager::Resizer::Processor).not_to have_received(:perform)
      end
    end

    context 'when given params are valid' do
      let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
      let(:selected_token2) { create(:token, :variant_selected, project:, index: 1) }
      let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }

      before do
        2.upto(5) { |index| create(:token, project:, index:) }
        result
        project.reload
      end

      it 'removes all selected tokens' do
        removed_tokens_ids = [selected_token1.id, selected_token2.id]
        expect(Token.where(id: removed_tokens_ids)).to be_empty
      end

      it 'creates one new token' do
        expected_nr_of_tokens = 5
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end

      it 'ensures the tokens\' indexes are correct' do
        expected_indexes = 0.upto(4)
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'uses the correct text for the new token' do
        token = project.tokens.first
        expect(token.t).to eq("#{selected_token1.t}#{selected_token2.t}")
      end

      it 'sets resized as true for the new token' do
        token = project.tokens.first
        expect(token).to be_resized
      end

      it 'returns result with success: true' do
        expect(result).to be_success
      end
    end
  end
end
