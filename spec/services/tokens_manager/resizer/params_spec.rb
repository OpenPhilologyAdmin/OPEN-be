# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Params, type: :model do
  let(:project) { create(:project) }
  let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
  let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }
  let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }

  let(:resource) do
    described_class.new(project:, selected_token_ids:)
  end

  describe '#initialize' do
    it 'assigns project' do
      expect(resource.project).to eq(project)
    end

    it 'assigns selected_tokens by using given selected_token_ids' do
      expect(resource.selected_tokens).to match_array([selected_token1, selected_token2])
    end
  end

  describe '#validations' do
    describe 'the project validations' do
      context 'when is nil' do
        let(:project) { nil }
        let(:selected_token1) { create(:token, :one_grouped_variant, index: 0) }
        let(:selected_token2) { create(:token, :one_grouped_variant, index: 1) }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:project]).to include(expected_error)
        end
      end
    end

    describe 'the selected_token_ids validations' do
      context 'when empty' do
        let(:selected_token_ids) { [nil, []].sample }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:selected_token_ids]).to include(expected_error)
        end
      end

      context 'when does not match the tokens from the project' do
        let(:selected_token_ids) { [create(:token).id] }
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'selected_token_ids.tokens_not_found'
          )
        end

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:selected_token_ids]).to include(expected_error)
        end
      end

      context 'when the selected tokens are not in order (some indexes missing)' do
        let(:selected_token1) { create(:token, project:, index: 0) }
        let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 5) }
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'selected_token_ids.tokens_not_in_order'
          )
        end

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:selected_token_ids]).to include(expected_error)
        end
      end
    end
  end
end
