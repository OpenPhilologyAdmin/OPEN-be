# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::GroupedVariantsUpdater, type: :service do
  let(:user) { create(:user, :admin, :approved) }
  let(:token) { create(:token, grouped_variants: [grouped_variant, grouped_variant2]) }
  let(:grouped_variant) { build(:token_grouped_variant, :insignificant) }
  let(:grouped_variant2) { build(:token_grouped_variant, :insignificant) }
  let(:params) do
    {
      grouped_variants:
                        [
                          {
                            id:       grouped_variant.id,
                            selected: true,
                            possible: true
                          },
                          {
                            id:       grouped_variant2.id,
                            selected: false,
                            possible: true
                          }
                        ]
    }
  end

  let(:service) { described_class.new(token:, user:, params:) }

  describe '#perform' do
    let!(:result) { service.perform }

    context 'when token data valid' do
      before { token.reload }

      it 'updates the grouped variants' do
        params[:grouped_variants].each do |grouped_variant_to_update|
          updated_grouped_variant = token.grouped_variants.find { |k| k.id == grouped_variant_to_update[:id] }
          expect(updated_grouped_variant.selected).to eq(grouped_variant_to_update[:selected])
          expect(updated_grouped_variant.possible).to eq(grouped_variant_to_update[:possible])
        end
      end

      it 'returns success result' do
        expect(result).to be_success
      end

      it 'includes token in the result' do
        expect(result.token).to eq(token)
      end
    end

    context 'when grouped variants missing' do
      let(:params) do
        { grouped_variants: nil }
      end

      before { token.reload }

      it 'does not update the token with new details' do
        expect(token.grouped_variants).not_to be_empty
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

      it 'the result token has proper errors' do
        expect(result.token.errors[:grouped_variants]).to match_array([I18n.t('errors.messages.blank')])
      end
    end
  end
end
