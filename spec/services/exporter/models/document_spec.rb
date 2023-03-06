# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Document, type: :model do
  describe '#to_export' do
    let(:resource) { described_class.new(paragraphs:) }
    let(:expected_value) do
      '{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}' \
        "{\\colortbl;\\red93\\green45\\blue239;\\red252\\green97\\blue69;}\n" \
        "#{content}\n}"
    end

    context 'when paragraphs empty' do
      let(:paragraphs) { [] }
      let(:content) { '' }

      it 'returns empty string inside document tag' do
        expect(resource.to_export).to eq(expected_value)
      end
    end

    context 'when contents include tokens' do
      let(:paragraphs) { [paragraph1, paragraph2] }

      context 'when there are strings to escape' do
        let(:paragraph1) { build(:exporter_paragraph, :with_nil_values) }
        let(:paragraph2) { build(:exporter_paragraph, :with_nil_values) }
        let(:content) do
          "#{paragraph1.to_export}#{paragraph2.to_export}".gsub(
            /#{FormattableT::NIL_VALUE_PLACEHOLDER}/, Exporter::Helpers::AsciiEscaper::NIL_VALUE_ASCII_PLACEHOLDER
          )
        end

        it 'returns combined :to_export results of given paragraphs with escaped nil value placeholders ' \
           'inside document tag' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when there are no strings to escape' do
        let(:paragraph1) { build(:exporter_paragraph) }
        let(:paragraph2) { build(:exporter_paragraph) }
        let(:content) { "#{paragraph1.to_export}#{paragraph2.to_export}" }

        it 'returns combined :to_export results of given paragraphs inside document tag' do
          expect(resource.to_export).to eq(expected_value)
        end
      end
    end
  end
end
