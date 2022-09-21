# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::TokenValuesWithOffsets, type: :model do
  let(:project) { create(:project) }
  let(:service) { described_class.new(tokens:, tokens_with_offsets:) }
  let(:result) { service.perform }

  before do
    allow(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset).to receive(:new)
      .at_least(:once)
      .and_call_original
    result
  end

  context 'when there are multiple tokens' do
    let(:token1) { create(:token, project:, index: 0) }
    let(:token2) { create(:token, project:, index: 2) }
    let(:tokens) { [token1, token2] }
    let(:tokens_with_offsets) do
      [
        {
          offset:   token2.t.length,
          token_id: token2.id
        },
        {
          offset:   1,
          token_id: token1.id
        }
      ]
    end

    it 'returns 2 records' do
      expect(result.size).to eq(2)
    end

    it 'returns records of correct class' do
      expect(result).to all(be_an(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset))
    end

    it 'returns records ordered by :token_index' do
      expect(result.first.token_index).to eq(token1.index)
      expect(result.last.token_index).to eq(token2.index)
    end

    it 'builds TokenValueWithOffset for the first given offset' do
      expected_attrs = {
        offset: 1,
        token:  token1
      }
      expect(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset).to have_received(:new)
        .with(**expected_attrs)
    end

    it 'builds TokenValueWithOffset for the second given token' do
      expected_attrs = {
        offset: token2.t.length,
        token:  token2
      }
      expect(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset).to have_received(:new)
        .with(**expected_attrs)
    end
  end

  context 'when there is only one token' do
    let(:token1) { create(:token, project:, index: 0) }
    let(:tokens) { [token1] }
    let(:tokens_with_offsets) do
      [
        {
          offset:   token1.t.length,
          token_id: token1.id
        },
        {
          offset:   2,
          token_id: token1.id
        }
      ]
    end

    it 'returns 2 records' do
      expect(result.size).to eq(2)
    end

    it 'returns records of correct class' do
      expect(result).to all(be_an(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset))
    end

    it 'returns records ordered by :offset' do
      expect(result.first.offset).to eq(2)
      expect(result.last.offset).to eq(token1.t.length)
    end

    it 'builds TokenValueWithOffset for the first given offset' do
      expected_attrs = {
        offset: token1.t.length,
        token:  token1
      }
      expect(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset).to have_received(:new)
        .with(**expected_attrs)
    end

    it 'builds TokenValueWithOffset for the second given offset' do
      expected_attrs = {
        offset: 2,
        token:  token1
      }
      expect(TokensManager::Resizer::Preparers::Models::TokenValueWithOffset).to have_received(:new)
        .with(**expected_attrs)
    end
  end
end
