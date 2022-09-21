# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::CalculateValueBeforeAndAfterToken, type: :model do
  let(:service) { described_class.new(tokens:, token:, value_before_selected_text:, selected_text:) }
  let(:result) { service.perform }

  context 'when there are multiple tokens' do
    let(:token1) { create(:token, index: 0) }
    let(:token2) { create(:token, index: 1) }
    let(:token3) { create(:token, index: 2) }
    let(:tokens) { [token1, token2, token3] }
    let(:token) { token2 }

    context 'when there should be value_before and value_after' do
      let(:value_before_selected_text) { token1.t[0..2] }
      let(:selected_text) { "#{token1.t[3..]}#{token2.t}#{token3.t[0..-2]}" }

      it 'returns correct value value_before' do
        expected_value = token1.t[3..]
        expect(result.value_before).to eq(expected_value)
      end

      it 'returns correct value value_after' do
        expected_value = token3.t[0..-2]

        expect(result.value_after).to eq(expected_value)
      end
    end

    context 'when there is only value_before' do
      let(:value_before_selected_text) { token1.t[0..2] }
      let(:tokens) { [token1, token2] }
      let(:selected_text) { "#{token1.t[3..]}#{token2.t}" }

      it 'returns correct value value_before' do
        expected_value = token1.t[3..]
        expect(result.value_before).to eq(expected_value)
      end

      it 'returns blank value_after' do
        expect(result.value_after).to be_blank
      end
    end

    context 'when there should be only value_after' do
      let(:value_before_selected_text) { '' }
      let(:tokens) { [token2, token3] }
      let(:selected_text) { "#{token2.t}#{token3.t[0..-2]}" }

      it 'returns blank value_before' do
        expect(result.value_before).to be_blank
      end

      it 'returns correct value value_after' do
        expected_value = token3.t[0..-2]

        expect(result.value_after).to eq(expected_value)
      end
    end
  end

  context 'when there is only one token' do
    let(:token1) { create(:token, index: 0) }
    let(:tokens) { [token1] }
    let(:token) { token1 }
    let(:value_before_selected_text) { '' }
    let(:selected_text) { token1.t }

    it 'returns empty value_before' do
      expect(result.value_before).to eq('')
    end

    it 'returns empty value_after' do
      expect(result.value_after).to eq('')
    end
  end
end
