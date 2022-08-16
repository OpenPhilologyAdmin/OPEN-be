# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Updater, type: :service do
  let(:user) { create(:user, :admin, :approved) }
  let(:token) { create(:token) }
  let(:grouped_variant) { build(:token_grouped_variant) }
  let(:variant) { build(:token_variant) }
  let(:params) do
    {
      grouped_variants: [grouped_variant],
      variants:         [variant]
    }
  end
  let(:service) { described_class.new(token:, user:, params:) }

  describe '#perform!' do
    let!(:result) { service.perform! }

    context 'when token data valid' do
      before { token.reload }

      context 'when updating grouped variants' do
        let(:params) do
          {
            grouped_variants: [grouped_variant].as_json
          }
        end

        it 'updates the token with grouped variants' do
          expect(token.grouped_variants).to match_array([grouped_variant])
        end
      end

      context 'when updating variants' do
        let(:params) do
          {
            variants: variants.as_json
          }
        end
        let(:variants) do
          [
            build(:token_variant, witness: 'A', t: 'lorim'),
            build(:token_variant, witness:  'B', t: 'lorem'),
            build(:token_variant, witness:  'C', t: 'lorim'),
            build(:token_variant, witness:  'D', t: 'loren')
          ]
        end
        let(:expected_grouped_variants) do
          [
            build(:token_grouped_variant, witnesses: %w[A C], t: 'lorim'),
            build(:token_grouped_variant, witnesses: ['B'], t: 'lorem'),
            build(:token_grouped_variant, witnesses: ['D'], t: 'loren')
          ]
        end

        before { token.reload }

        it 'updates the token with variants' do
          expect(token.variants).to match_array(variants)
        end

        it 'recalculates grouped_variants and clears the previous selections' do
          expect(token.grouped_variants).to match_array(expected_grouped_variants)
        end
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