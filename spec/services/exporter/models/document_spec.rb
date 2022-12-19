# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Document, type: :model do
  describe '#to_export' do
    let(:resource) { described_class.new(paragraphs:) }

    context 'when paragraphs empty' do
      let(:paragraphs) { [] }

      it 'returns empty string' do
        expect(resource.to_export).to eq('')
      end
    end

    context 'when contents include tokens' do
      let(:paragraph1) { build(:exporter_paragraph) }
      let(:paragraph2) { build(:exporter_paragraph) }
      let(:paragraphs) { [paragraph1, paragraph2] }

      it 'returns combined :to_export results of given paragraphs' do
        expect(resource.to_export).to eq("#{paragraph1.to_export}#{paragraph2.to_export}")
      end
    end
  end
end
