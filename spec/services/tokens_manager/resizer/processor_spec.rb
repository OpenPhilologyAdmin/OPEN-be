# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processor, type: :service do
  let(:project) { create(:project) }
  let(:prev_starting_index) { 3 }
  let(:prev_token) { create(:token, project:, index: prev_starting_index) }
  let(:prev_token2) { create(:token, project:, index: prev_starting_index + 1) }
  let(:selected_tokens) { [prev_token, prev_token2] }
  let(:expected_indexes) { prev_starting_index.upto(prev_starting_index + expected_nr_of_tokens - 1).to_a }

  before do
    index = selected_tokens.last.index + 1
    3.times do
      create(:token, project:, index:)
      index += 1
    end
    described_class.new(new_tokens:, selected_tokens:, project:).perform
    project.reload
  end

  describe '#perform' do
    context 'when numbers of token in the project is not changed' do
      let(:new_tokens) { build_list(:token, 2, project:, index: nil) }
      let(:expected_nr_of_tokens) { 5 }

      it 'saves new tokens' do
        expect(new_tokens).to all(be_persisted)
      end

      it 'assigns correct indexes to the new tokens' do
        index = prev_starting_index
        new_tokens.each do |new_token|
          expect(new_token.index).to eq(index)
          index += 1
        end
      end

      it 'deletes selected tokens' do
        expect(Token.where(id: selected_tokens.pluck(:id))).to be_empty
      end

      it 'does not change other tokens indexes' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end

    context 'when there will be more tokens in the project than it was before' do
      let(:new_tokens) { build_list(:token, 3, project:, index: nil) }
      let(:expected_nr_of_tokens) { 6 }

      it 'saves new tokens' do
        expect(new_tokens).to all(be_persisted)
      end

      it 'assigns correct indexes to the new tokens' do
        index = prev_starting_index
        new_tokens.each do |new_token|
          expect(new_token.index).to eq(index)
          index += 1
        end
      end

      it 'deletes selected tokens' do
        expect(Token.where(id: selected_tokens.pluck(:id))).to be_empty
      end

      it 'updates other tokens indexes by + 1' do
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
      let(:new_tokens) { build_list(:token, 1, project:, index: nil) }
      let(:expected_nr_of_tokens) { 4 }

      it 'saves new tokens' do
        expect(new_tokens).to all(be_persisted)
      end

      it 'deletes selected tokens' do
        expect(Token.where(id: selected_tokens.pluck(:id))).to be_empty
      end

      it 'assigns correct indexes to the new tokens' do
        new_token = new_tokens.first
        expect(new_token.index).to eq(prev_starting_index)
      end

      it 'updates other tokens indexes by - 3' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end

    context 'when one of the selected tokens is still in use' do
      let(:new_tokens) do
        [
          build(:token, project:, index: nil),
          prev_token,
          build(:token, project:, index: nil)
        ]
      end
      let(:expected_nr_of_tokens) { 6 }

      it 'saves new tokens' do
        expect(new_tokens).to all(be_persisted)
      end

      it 'assigns correct indexes to the new tokens' do
        index = prev_starting_index
        new_tokens.each do |new_token|
          expect(new_token.index).to eq(index)
          index += 1
        end
      end

      it 'deletes selected tokens except the one that is still in use' do
        removed_tokens = selected_tokens - [prev_token]
        expect(Token.where(id: removed_tokens.pluck(:id))).to be_empty
      end

      it 'updates other tokens indexes by + 1' do
        expect(project.tokens.pluck(:index)).to match_array(expected_indexes)
      end

      it 'keeps correct number of tokens in the project' do
        expect(project.tokens.size).to eq(expected_nr_of_tokens)
      end
    end
  end
end
