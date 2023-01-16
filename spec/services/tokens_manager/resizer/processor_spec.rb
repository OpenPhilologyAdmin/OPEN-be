# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processor, type: :service do
  describe '#perform' do
    let(:project) { create(:project) }
    let(:prev_starting_index) { 3 }
    let(:selected_tokens) do
      index = prev_starting_index
      tokens = []
      4.times do
        tokens << create(:token, project:, index:)
        index += 1
      end
      tokens
    end
    let(:prepared_token) { build(:token, project:, index: prev_starting_index) }
    let(:expected_indexes) { [3, 4, 5, 6] }
    let(:expected_nr_of_tokens) { 4 }

    before do
      index = selected_tokens.last.index + 1
      # create 3 tokens after the selection
      3.times do
        create(:token, project:, index:)
        index += 1
      end
      described_class.new(prepared_token:, selected_tokens:, project:).perform
      project.reload
    end

    it 'saves new token' do
      expect(prepared_token).to be_persisted
    end

    it 'deletes selected tokens' do
      tokens_to_remove_ids = selected_tokens.pluck(:id)
      expect(Token.where(id: tokens_to_remove_ids)).to be_empty
    end

    it 'assigns correct index to the new token' do
      expect(prepared_token.index).to eq(prev_starting_index)
    end

    it 'decreases the indexes of tokens that were after the selection by nr of removed tokens' do
      expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
    end

    it 'keeps correct number of tokens in the project' do
      expect(project.tokens.size).to eq(expected_nr_of_tokens)
    end
  end
end
