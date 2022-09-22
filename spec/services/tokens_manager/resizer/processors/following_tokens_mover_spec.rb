# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processors::FollowingTokensMover, type: :service do
  let(:project) { create(:project) }
  let(:previous_last_index) { 3 }
  let(:following_tokens_indexes) { project.tokens.pluck(:index) }

  before do
    following_tokens_index = previous_last_index + 1
    3.times do
      create(:token, project:, index: following_tokens_index)
      following_tokens_index += 1
    end
    described_class.new(project:, previous_last_index:, new_last_index:).perform
    project.reload
  end

  describe '#perform' do
    context 'when the previous_last_index is the same as the new_last_index' do
      let(:new_last_index) { 3 }
      let(:expected_indexes) { [4, 5, 6] }

      it 'does not change the indexes of tokens' do
        expect(following_tokens_indexes).to match_array(expected_indexes)
      end
    end

    context 'when the new_last_index is higher than the previous_last_index' do
      let(:new_last_index) { previous_last_index + 2 }
      let(:expected_indexes) { [6, 7, 8] }

      it 'increases the indexes of tokens with indexes higher than previous_last_index by 2' do
        expect(following_tokens_indexes).to match_array(expected_indexes)
      end
    end

    context 'when the new_last_index is lower than the previous_last_index' do
      let(:new_last_index) { previous_last_index - 1 }
      let(:expected_indexes) { [3, 4, 5] }

      it 'decreases the indexes of tokens with indexes higher than previous_last_index by 1' do
        expect(following_tokens_indexes).to match_array(expected_indexes)
      end
    end
  end
end
