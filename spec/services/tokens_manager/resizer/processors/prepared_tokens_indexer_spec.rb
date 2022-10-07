# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processors::PreparedTokensIndexer, type: :service do
  let(:starting_index) { 3 }
  let(:project) { build(:project) }
  let(:token1) { build(:token, project:, index: nil) }
  let(:token2) { build(:token, project:, index: nil) }
  let(:token3) { build(:token, project:, index: nil) }
  let(:prepared_tokens) { [token1, token2, token3] }

  describe '#perform' do
    before do
      described_class.new(starting_index:, prepared_tokens:).perform
    end

    it 'assigns correct index to token1' do
      expect(token1.index).to eq(starting_index)
    end

    it 'assigns correct index to token2' do
      expect(token2.index).to eq(starting_index + 1)
    end

    it 'assigns correct index to token3' do
      expect(token3.index).to eq(starting_index + 2)
    end
  end
end
