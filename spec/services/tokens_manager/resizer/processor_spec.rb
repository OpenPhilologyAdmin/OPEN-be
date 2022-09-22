# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processor, type: :service do
  let(:project) { create(:project) }
  let(:prev_starting_index) { 3 }
  let(:selected_token1) { create(:token, project:, index: prev_starting_index) }
  let(:selected_token2) { create(:token, project:, index: prev_starting_index + 1) }
  let(:selected_tokens) { [selected_token1, selected_token2] }

  before do
    index = selected_tokens.last.index
    3.times do
      index += 1
      create(:token, project:, index:)
    end
    described_class.new(prepared_tokens:, selected_tokens:, project:).perform
    project.reload
  end

  describe '#perform' do
    context 'when the number of tokens in the project has not been not changed' do
      let(:prepared_tokens) { build_list(:token, 2, project:, index: nil) }
      let(:expected_indexes) { [3, 4, 5, 6, 7] }
      let(:expected_nr_of_tokens) { 5 }

      it 'saves new tokens' do
        expect(prepared_tokens).to all(be_persisted)
      end

      it 'assigns correct indexes to the new tokens' do
        index = prev_starting_index
        prepared_tokens.each do |new_token|
          expect(new_token.index).to eq(index)
          index += 1
        end
      end

      it 'deletes selected tokens' do
        tokens_to_remove_ids = selected_tokens.pluck(:id)
        expect(Token.where(id: tokens_to_remove_ids)).to be_empty
      end

      it 'does not change the indexes of tokens that were after the selected_text' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end

    context 'when there will be more tokens in the project than it was before' do
      let(:prepared_tokens) { build_list(:token, 3, project:, index: nil) }
      let(:expected_indexes) { [3, 4, 5, 6, 7, 8] }
      let(:expected_nr_of_tokens) { 6 }

      it 'saves new tokens' do
        expect(prepared_tokens).to all(be_persisted)
      end

      it 'assigns correct indexes to the new tokens' do
        index = prev_starting_index
        prepared_tokens.each do |new_token|
          expect(new_token.index).to eq(index)
          index += 1
        end
      end

      it 'deletes selected tokens' do
        tokens_to_remove_ids = selected_tokens.pluck(:id)
        expect(Token.where(id: tokens_to_remove_ids)).to be_empty
      end

      it 'increases the indexes of tokens that were after the selection by 1' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end

    context 'when there will be less tokens in the project than it was before' do
      let(:selected_tokens) do
        index = prev_starting_index
        tokens = []
        4.times do
          tokens << create(:token, project:, index:)
          index += 1
        end
        tokens
      end
      let(:prepared_tokens) { build_list(:token, 1, project:, index: nil) }
      let(:expected_indexes) { [3, 4, 5, 6] }
      let(:expected_nr_of_tokens) { 4 }

      it 'saves new tokens' do
        expect(prepared_tokens).to all(be_persisted)
      end

      it 'deletes selected tokens' do
        tokens_to_remove_ids = selected_tokens.pluck(:id)
        expect(Token.where(id: tokens_to_remove_ids)).to be_empty
      end

      it 'assigns correct indexes to the new tokens' do
        new_token = prepared_tokens.first
        expect(new_token.index).to eq(prev_starting_index)
      end

      it 'decreases the indexes of tokens that were after the selection by 3' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end
  end
end
