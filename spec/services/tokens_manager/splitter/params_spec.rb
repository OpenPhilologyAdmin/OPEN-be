# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Splitter::Params, type: :model do
  let(:project) { create(:project, witnesses: [Witness.new(siglum: 'A'), Witness.new(siglum: 'B')]) }
  let(:source_token) do
    create(:token, project:, index: 0, variants: [
             build(:token_variant,
                   witness: 'A',
                   t:       'This is a nice text'),

             build(:token_variant,
                   witness: 'B',
                   t:       'This is quite a bad text')
           ])
  end
  let(:other_token) { create(:token, project:, index: 1) }

  let(:new_variants) do
    [
      {
        witness: 'A',
        t:       'This is{scissors} a nice text'
      },
      {
        witness: 'B',
        t:       'This is quite a b{scissors}ad text'
      }
    ]
  end

  let(:resource) { described_class.new(project:, new_variants:, source_token:) }

  describe '#initialize' do
    it 'assigns project' do
      expect(resource.project).to eq(project)
    end

    it 'assigns new_variants' do
      expect(resource.new_variants).to eq(new_variants)
    end

    it 'assigns source_token' do
      expect(resource.source_token).to eq(source_token)
    end
  end

  describe '#validations' do
    describe 'project validations' do
      context 'when is nil' do
        let(:project) { nil }
        let(:source_token) { create(:token, :one_grouped_variant, index: 0) }
        let(:new_variants) { [{ witness: 'A', t: 'nice {scissors} variant' }] }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it { expect(resource).not_to be_valid }

        it 'assigns correct error' do
          resource.valid?
          expect(resource.errors[:project]).to include(expected_error)
        end
      end
    end

    describe 'new_variants validations' do
      context 'when empty' do
        let(:new_variants) { nil }
        let(:expected_error) { I18n.t('errors.messages.blank') }

        it { expect(resource).not_to be_valid }

        it 'assigns correct error' do
          resource.valid?
          expect(resource.errors[:new_variants]).to include(expected_error)
        end
      end

      context 'when not empty' do
        let(:source_token) do
          create(:token, project:, index: 0, variants: [
                   build(:token_variant,
                         witness: 'A',
                         t:       'This is a nice text'),

                   build(:token_variant,
                         witness: 'B',
                         t:       'This is quite a bad text')
                 ])
        end

        let(:new_variants) do
          [
            {
              witness: 'A',
              t:       'This is{scissors} a nice text'
            },
            {
              witness: 'B',
              t:       'This is quite a b{scissors}ad text'
            }
          ]
        end

        context 'when new_variants are correct' do
          it { expect(resource).to be_valid }
        end

        context 'when splitter phrase is missing' do
          let(:new_variants) { [{ witness: 'A', t: 'Try to match me' }] }
          let(:expected_error) do
            I18n.t(
              'activemodel.errors.models.tokens_manager/splitter/params.attributes.' \
              'new_variants.splitter_phrase_missing'
            )
          end

          it { expect(resource).not_to be_valid }

          it 'assigns correct error' do
            resource.valid?
            expect(resource.errors[:new_variants]).to include(expected_error)
          end
        end

        context 'when new_variants do not match source_token variants' do
          let(:source_token) do
            create(:token, project:, index: 0, variants: [
                     build(:token_variant,
                           witness: 'A',
                           t:       'This is a nice text'),

                     build(:token_variant,
                           witness: 'B',
                           t:       'This is quite a bad text')
                   ])
          end

          let(:new_variants) do
            [
              {
                witness: 'A',
                t:       'This is{scissors} a nice text'
              },
              {
                witness: 'B',
                t:       'Injected some a b{scissors}ad random text'
              }
            ]
          end

          let(:expected_error) do
            I18n.t(
              'activemodel.errors.models.tokens_manager/splitter/params.attributes.' \
              'new_variants.invalid_variant_text'
            )
          end

          it { expect(resource).not_to be_valid }

          it 'assigns correct error' do
            resource.valid?
            expect(resource.errors[:new_variants]).to include(expected_error)
          end
        end
      end
    end
  end
end
