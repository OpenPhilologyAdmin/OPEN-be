# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Params, type: :model do
  let(:project) { create(:project) }
  let(:tokens_with_offsets) do
    [
      {
        offset:   0,
        token_id: selected_token1.id
      },
      {
        offset:   selected_token2.t.size,
        token_id: selected_token2.id
      }
    ]
  end
  let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
  let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 0) }
  let(:selected_text) { "#{selected_token1.t}#{selected_token2.t}" }
  let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }

  let(:resource) do
    described_class.new(project:, selected_text:, selected_token_ids:, tokens_with_offsets:)
  end

  describe '#initialize' do
    it 'assigns project' do
      expect(resource.project).to eq(project)
    end

    it 'assigns selected_text' do
      expect(resource.selected_text).to eq(selected_text)
    end

    it 'assigns selected_tokens by using given selected_token_ids' do
      expect(resource.selected_tokens).to match_array([selected_token1, selected_token2])
    end

    it 'assigns tokens_with_offsets' do
      expect(resource.tokens_with_offsets).to eq(tokens_with_offsets)
    end

    context 'when there are no tokens with multiple readings in the selection' do
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 0) }

      it 'leaves selected_multiple_readings_token as nil' do
        expect(resource.selected_multiple_readings_token).to be_nil
      end
    end

    context 'when there is a token with multiple readings in the selection' do
      let(:selected_token2) { create(:token, project:, index: 0) }
      let(:selected_multiple_readings_token) { selected_token2 }

      it 'assigns such token as a selected_multiple_readings_token' do
        expect(resource.selected_multiple_readings_token).to eq(selected_multiple_readings_token)
      end
    end
  end
end
