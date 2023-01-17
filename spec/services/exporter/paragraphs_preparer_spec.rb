# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::ParagraphsPreparer, type: :service do
  let(:project) { create(:project) }
  let(:exporter_options) { build(:exporter_options, footnote_numbering: true) }
  let(:apparatus_options) { build(:apparatus_options) }

  let(:service) { described_class.new(project:, exporter_options:, apparatus_options:) }

  describe '#perform' do
    let(:result) { service.perform }

    before do
      token1
      token2
    end

    context 'when there are apparatuses' do
      let(:token1) { create(:token, :variant_selected_and_secondary, project:, index: 1) }
      let(:token2) { create(:token, project:, index: 2) }
      let(:expected_exporter_tokens) do
        [
          build(:exporter_token,
                value:                 token1.t,
                footnote_numbering:    true,
                apparatus_entry_index: 1),
          build(:exporter_token,
                value:                 token2.t,
                footnote_numbering:    false,
                apparatus_entry_index: nil)
        ]
      end
      let(:expected_apparatuses) do
        [
          build(:exporter_apparatus,
                selected_variant:       token1.selected_variant,
                secondary_variants:     token1.secondary_variants,
                insignificant_variants: token1.insignificant_variants,
                apparatus_options:,
                index:                  1)
        ]
      end

      it 'returns two paragraphs' do
        expect(result.size).to eq(2)
      end

      it 'adds the tokens to the first paragraph with the correct styling' do
        paragraph        = result.first
        expected_content = build(:exporter_paragraph, contents: expected_exporter_tokens)
        expect(paragraph.to_export).to eq(expected_content.to_export)
      end

      it 'adds the apparatuses to the second paragraph with the correct styling' do
        paragraph        = result.second
        expected_content = build(:exporter_paragraph, contents: expected_apparatuses)
        expect(paragraph.to_export).to eq(expected_content.to_export)
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

      it 'adds the tokens to the first paragraph with the correct styling' do
        paragraph        = result.first
        expected_content = build(:exporter_paragraph, contents: expected_exporter_tokens)
        expect(paragraph.to_export).to eq(expected_content.to_export)
      end
    end
  end
end
