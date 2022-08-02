# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Updater, type: :service do
  let(:user) { create(:user, :admin, :approved) }
  let(:token) { create(:token) }
  let(:grouped_variant) { build(:token_grouped_variant) }
  let(:params) { { grouped_variants: [grouped_variant] } }
  let(:service) { described_class.new(token:, user:, params:) }

  describe '#perform!' do
    let!(:result) { service.perform! }

    context 'when token data valid' do
      before { token.reload }

      it 'updates the token with new details' do
        expect(token.grouped_variants).to match_array([grouped_variant])
      end

      it 'sets the current user as last_editor of project' do
        expect(token.project.last_editor).to eq(user)
      end

      it 'returns success result' do
        expect(result).to be_success
      end

      it 'includes token in the result' do
        expect(result.token).to eq(token)
      end
    end

    context 'when token data is not valid' do
      let(:params) { { variants: nil } }

      before { token.reload }

      it 'does not update the token with new details' do
        expect(token.variants).not_to be_empty
      end

      it 'does not set the current user as last_editor of project' do
        expect(token.project.last_editor).not_to eq(user)
      end

      it 'returns failure result' do
        expect(result).not_to be_success
      end

      it 'includes token in the result' do
        expect(result.token).to eq(token)
      end
    end
  end
end
