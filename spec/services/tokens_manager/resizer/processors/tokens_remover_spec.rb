# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Processors::TokensRemover, type: :service do
  describe '#perform' do
    let(:project) { create(:project) }
    let(:token1) { create(:token, project:) }
    let(:token2) { create(:token, project:) }
    let(:token3) { create(:token, project:) }
    let(:tokens_to_remove) { [token2, token3] }
    let(:removed_tokens_ids) { [token2.id, token3.id] }

    before do
      token1
      described_class.new(project:, tokens_to_remove:).perform
    end

    it 'removes the specified tokens from the Token.default_scope' do
      expect(Token.where(id: removed_tokens_ids)).to be_empty
    end

    it 'removes the specified tokens from the project tokens' do
      expect(project.reload.tokens.where(id: removed_tokens_ids)).to be_empty
    end

    it 'uses the soft delete to remove the tokens' do
      tokens_to_remove.each do |soft_deleted_token|
        expect(soft_deleted_token.reload).to be_persisted
        expect(soft_deleted_token).to be_deleted
      end
    end

    it 'does not remove other project tokens' do
      expect(token1.reload).to be_persisted
      expect(token1).not_to be_deleted
    end
  end
end
