# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::ValueBeforeAndAfterSelectedTextCalculator, type: :model do
  let(:project) { create(:project) }
  let(:service) { described_class.new(tokens:, tokens_with_offsets:) }

  context 'when there are multiple tokens' do
    let(:token1) { create(:token, project:, index: 0) }
    let(:token2) { create(:token, project:, index: 2) }
    let(:tokens) { [token1, token2] }
    let(:token1_offset) { 1 }
    let(:token2_offset) { token2.t.length - 1 }
    let(:tokens_with_offsets) do
      [
        {
          offset:   token1_offset,
          token_id: token1.id
        },
        {
          offset:   token2_offset,
          token_id: token2.id
        }
      ]
    end

    describe '#value_before' do
      it 'returns correct value' do
        expected_value = TokensManager::Resizer::Preparers::Models::TokenValueWithOffset.new(
          token:  token1,
          offset: token1_offset
        )
        expect(service.value_before).to eq(expected_value.value_before)
      end
    end

    describe '#value_after' do
      it 'returns correct value' do
        expected_value = TokensManager::Resizer::Preparers::Models::TokenValueWithOffset.new(
          token:  token2,
          offset: token2_offset
        )
        expect(service.value_after).to eq(expected_value.value_after)
      end
    end
  end

  context 'when there is only one token' do
    let(:token1) { create(:token, project:, index: 0) }
    let(:tokens) { [token1] }
    let(:tokens_with_offsets) do
      [
        {
          offset:   2,
          token_id: token1.id
        },
        {
          offset:   token1.t.length,
          token_id: token1.id
        }
      ]
    end

    describe '#value_before' do
      it 'returns correct value' do
        expected_value = TokensManager::Resizer::Preparers::Models::TokenValueWithOffset.new(
          token:  token1,
          offset: 2
        )
        expect(service.value_before).to eq(expected_value.value_before)
      end
    end

    describe '#value_after' do
      it 'returns correct value' do
        expected_value = TokensManager::Resizer::Preparers::Models::TokenValueWithOffset.new(
          token:  token1,
          offset: token1.t.length
        )
        expect(service.value_after).to eq(expected_value.value_after)
      end
    end
  end
end
