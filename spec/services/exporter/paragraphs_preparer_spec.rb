# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::ParagraphsPreparer, type: :service do
  let(:project) { create(:project) }
  let(:exporter_options) { build(:exporter_options, footnote_numbering: true) }
  let(:apparatus_options) { build(:apparatus_options) }

  let(:service) { described_class.new(project:, exporter_options:, apparatus_options:) }

  describe '#perform' do
    let(:result) { service.perform }
    let(:token1) { create(:token, :variant_selected_and_secondary, project:, index: 1) }
    let(:token2) { create(:token, project:, index: 2) }
    let(:expected_exporter_tokens) do
      [
        Exporter::Models::Token.new(
          value:              token1.t,
          footnote_numbering: true,
          index:              1
        ),
        Exporter::Models::Token.new(
          value:              token2.t,
          footnote_numbering: false,
          index:              nil
        )
      ]
    end
    let(:expected_apparatuses) do
      [
        Exporter::Models::Apparatus.new(
          selected_variant:       token1.selected_variant,
          secondary_variants:     token1.secondary_variants,
          insignificant_variants: token1.insignificant_variants,
          apparatus_options:,
          index:                  1
        )
      ]
    end

    before do
      token1
      token2
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
end
