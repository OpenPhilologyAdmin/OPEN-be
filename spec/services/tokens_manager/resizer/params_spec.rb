# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Params, type: :model do
  let(:project) { create(:project) }
  let(:tokens_with_offsets) do
    [
      {
        offset:   0,
        token_id: selected_token1.id
      },
      {
        offset:   selected_token2.t.size,
        token_id: selected_token2.id
      }
    ]
  end
  let(:selected_token1) { create(:token, :one_grouped_variant, project:, index: 0) }
  let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }
  let(:selected_text) { "#{selected_token1.t}#{selected_token2.t}" }
  let(:selected_token_ids) { [selected_token1.id, selected_token2.id] }

  let(:resource) do
    described_class.new(project:, selected_text:, selected_token_ids:, tokens_with_offsets:)
  end

  describe '#initialize' do
    it 'assigns project' do
      expect(resource.project).to eq(project)
    end

    it 'assigns selected_text' do
      expect(resource.selected_text).to eq(selected_text)
    end

    it 'assigns selected_tokens by using given selected_token_ids' do
      expect(resource.selected_tokens).to match_array([selected_token1, selected_token2])
    end

    it 'assigns tokens_with_offsets' do
      expect(resource.tokens_with_offsets).to eq(tokens_with_offsets)
    end

    context 'when there are no tokens with multiple readings in the selection' do
      let(:selected_token2) { create(:token, :one_grouped_variant, project:, index: 1) }

      it 'leaves selected_multiple_readings_token as nil' do
        expect(resource.selected_multiple_readings_token).to be_nil
      end
    end

    context 'when there is a token with multiple readings in the selection' do
      let(:selected_token2) { create(:token, project:, index: 1) }
      let(:selected_multiple_readings_token) { selected_token2 }

      it 'assigns such token as a selected_multiple_readings_token' do
        expect(resource.selected_multiple_readings_token).to eq(selected_multiple_readings_token)
      end
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

    describe 'the selected_text validations' do
      context 'when empty' do
        let(:selected_text) { [nil, ''].sample }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:selected_text]).to include(expected_error)
        end
      end

      context 'when not empty' do
        context 'when is a part of the full text of the selected tokens' do
          let(:selected_text) { "#{selected_token1.t}#{selected_token2.t}" }

          it 'is valid' do
            expect(resource).to be_valid
          end
        end

        context 'when it does not match the full text of selected tokens' do
          let(:selected_text) { 'text-that-is-not-present-in-selected-tokens' }
          let(:expected_error) do
            I18n.t(
              'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
              'selected_text.does_not_match_full_text_of_selected_tokens'
            )
          end

          it 'is not valid' do
            expect(resource).not_to be_valid
          end

          it 'assigns correct error to the field' do
            resource.valid?
            expect(resource.errors[:selected_text]).to include(expected_error)
          end
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

      context 'when there is more than one multiple readings token in the selection' do
        let(:selected_token1) { create(:token, project:, index: 0) }
        let(:selected_token2) { create(:token, project:, index: 1) }
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'selected_token_ids.more_than_one_multiple_readings_token'
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

    describe 'the tokens_with_offsets validations' do
      context 'when empty' do
        let(:tokens_with_offsets) { [nil, []].sample }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:tokens_with_offsets]).to include(expected_error)
        end
      end

      context 'when token IDs does not match the selected_token_ids' do
        let(:tokens_with_offsets) do
          [
            {
              offset:   0,
              token_id: create(:token).id
            },
            {
              offset:   selected_token2.t.size,
              token_id: selected_token2.id
            }
          ]
        end
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'tokens_with_offsets.invalid_token_ids'
          )
        end

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:tokens_with_offsets]).to include(expected_error)
        end
      end

      context 'when the given offsets are not 0 or a positive integer' do
        let(:tokens_with_offsets) do
          [
            {
              offset:   '-5.5',
              token_id: selected_token1.id
            },
            {
              offset:   'a',
              token_id: selected_token2.id
            }
          ]
        end
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'tokens_with_offsets.invalid_offsets'
          )
        end

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:tokens_with_offsets]).to include(expected_error)
        end
      end

      context 'when user tries to divide multiple readings token' do
        let(:selected_token2) { create(:token, project:, index: 1) }
        let(:selected_multiple_readings_token) { selected_token2 }
        let(:tokens_with_offsets) do
          [
            {
              offset:   1,
              token_id: selected_token1.id
            },
            {
              offset:   selected_token2.t.size - 2,
              token_id: selected_token2.id
            }
          ]
        end
        let(:expected_error) do
          I18n.t(
            'activemodel.errors.models.tokens_manager/resizer/params.attributes.' \
            'tokens_with_offsets.multiple_readings_token_cannot_be_divided'
          )
        end

        it 'is not valid' do
          expect(resource).not_to be_valid
        end

        it 'assigns correct error to the field' do
          resource.valid?
          expect(resource.errors[:tokens_with_offsets]).to include(expected_error)
        end
      end
    end
  end
end
