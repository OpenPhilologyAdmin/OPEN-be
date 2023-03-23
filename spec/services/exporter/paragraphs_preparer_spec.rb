# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::ParagraphsPreparer, type: :service do
  let(:project) { create(:project) }
  let(:apparatus_options) { build(:apparatus_options, footnote_numbering: true) }

  let(:service) { described_class.new(project:, apparatus_options:) }

  describe '#perform' do
    let(:result) { service.perform }

    before do
      token1
      token2
    end

    context 'when there are apparatuses' do
      let(:token1) { create(:token, :variant_selected_and_secondary, project:, index: 1) }
      let(:token2) { create(:token, project:, index: 2) }

      context 'when apparatus should be included' do
        context 'when the last paragraph includes token' do
          it 'returns three paragraphs' do
            expect(result.size).to eq(3)
          end

          it 'adds the token to the first paragraph with the correct styling' do
            paragraph = result.first
            expected_token = build(:exporter_token,
                                   value:                 token1.t,
                                   footnote_numbering:    true,
                                   apparatus_entry_index: 1)
            expected_content = build(:exporter_paragraph, contents: [expected_token])
            expect(paragraph.to_export).to eq(expected_content.to_export)
          end

          it 'adds the apparatus of first token to the second paragraph with the correct styling' do
            paragraph = result.second
            expected_apparatus = build(:exporter_apparatus,
                                       selected_variant:       token1.selected_variant,
                                       secondary_variants:     token1.secondary_variants,
                                       insignificant_variants: token1.insignificant_variants,
                                       apparatus_entry_index:  1,
                                       apparatus_options:)
            expected_content = build(:exporter_paragraph, contents: [expected_apparatus])
            expect(paragraph.to_export).to eq(expected_content.to_export)
          end

          it 'adds the second token to the third paragraph with the correct styling' do
            paragraph = result.third
            expected_token = build(:exporter_token,
                                   value:                 token2.t,
                                   footnote_numbering:    false,
                                   apparatus_entry_index: nil)
            expected_content = build(:exporter_paragraph, contents: [expected_token])
            expect(paragraph.to_export).to eq(expected_content.to_export)
          end
        end

        context 'when the last paragraph includes apparatus' do
          let(:token1) { create(:token, project:, index: 1) }
          let(:token2) { create(:token, :variant_selected_and_secondary, project:, index: 2) }

          let(:expected_exporter_tokens) do
            [
              build(:exporter_token,
                    value:                 token1.t,
                    footnote_numbering:    false,
                    apparatus_entry_index: nil),
              build(:exporter_token,
                    value:                 token2.t,
                    footnote_numbering:    true,
                    apparatus_entry_index: 1)
            ]
          end

          it 'returns three paragraphs' do
            expect(result.size).to eq(2)
          end

          it 'adds the tokens to the first paragraph with the correct styling' do
            paragraph = result.first
            expected_content = build(:exporter_paragraph, contents: expected_exporter_tokens)
            expect(paragraph.to_export).to eq(expected_content.to_export)
          end

          it 'adds the apparatus to the second paragraph with the correct styling' do
            paragraph = result.second
            expected_apparatus = build(:exporter_apparatus,
                                       selected_variant:       token2.selected_variant,
                                       secondary_variants:     token2.secondary_variants,
                                       insignificant_variants: token2.insignificant_variants,
                                       apparatus_entry_index:  1,
                                       apparatus_options:)
            expected_content = build(:exporter_paragraph, contents: [expected_apparatus])
            expect(paragraph.to_export).to eq(expected_content.to_export)
          end
        end
      end

      context 'when apparatus shouldn\'t be included (significant_readings: false and insignificant_readings: false)' do
        let(:apparatus_options) do
          build(:apparatus_options, significant_readings: false, insignificant_readings: false)
        end

        let(:expected_tokens) do
          [
            build(:exporter_token,
                  value:                 token1.t,
                  footnote_numbering:    false,
                  apparatus_entry_index: nil),
            build(:exporter_token,
                  value:                 token2.t,
                  footnote_numbering:    false,
                  apparatus_entry_index: nil)
          ]
        end

        it 'returns one paragraph' do
          expect(result.size).to eq(1)
        end

        it 'adds all tokens to the first paragraph with the correct styling' do
          paragraph        = result.first
          expected_content = build(:exporter_paragraph, contents: expected_tokens)
          expect(paragraph.to_export).to eq(expected_content.to_export)
        end
      end

      context 'when apparatus has no content for the given settings' do
        let(:token1) { create(:token, :variant_selected, project:, index: 1) }
        let(:token2) { create(:token, :variant_selected, project:, index: 2) }
        let(:apparatus_options) do
          build(:apparatus_options, significant_readings: true, insignificant_readings: false)
        end

        let(:expected_tokens) do
          [
            build(:exporter_token,
                  value:                 token1.t,
                  footnote_numbering:    false,
                  apparatus_entry_index: nil),
            build(:exporter_token,
                  value:                 token2.t,
                  footnote_numbering:    false,
                  apparatus_entry_index: nil)
          ]
        end

        it 'returns one paragraph' do
          expect(result.size).to eq(1)
        end

        it 'adds all tokens to the first paragraph with the correct styling' do
          paragraph        = result.first
          expected_content = build(:exporter_paragraph, contents: expected_tokens)
          expect(paragraph.to_export).to eq(expected_content.to_export)
        end
      end
    end

    context 'when there are no apparatuses' do
      let(:token1) { create(:token, project:, index: 1) }
      let(:token2) { create(:token, project:, index: 2) }
      let(:expected_exporter_tokens) do
        [
          build(:exporter_token,
                value:                 token1.t,
                footnote_numbering:    false,
                apparatus_entry_index: nil),
          build(:exporter_token,
                value:                 token2.t,
                footnote_numbering:    false,
                apparatus_entry_index: nil)
        ]
      end

      it 'returns one paragraph' do
        expect(result.size).to eq(1)
      end

      it 'adds all the tokens to the first paragraph with the correct styling' do
        paragraph        = result.first
        expected_content = build(:exporter_paragraph, contents: expected_exporter_tokens)
        expect(paragraph.to_export).to eq(expected_content.to_export)
      end
    end
  end
end
