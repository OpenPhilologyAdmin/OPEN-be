# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Paragraph, type: :model do
  describe '#to_export' do
    let(:resource) do
      described_class.new(
        contents:
      )
    end

    context 'when contents empty' do
      let(:contents) { [] }

      it 'returns empty string inside paragraph tags' do
        expect(resource.to_export).to eq('{\par  \par}')
      end
    end

    context 'when contents include tokens' do
      let(:token1) { build(:exporter_token) }
      let(:token2) { build(:exporter_token) }
      let(:contents) { [token1, token2] }

      it 'returns combined :to_export results of given tokens inside paragraph tags' do
        expect(resource.to_export).to eq("{\\par #{token1.to_export}#{token2.to_export} \\par}")
      end
    end

    context 'when contents include apparatuses' do
      let(:apparatus1) { build(:exporter_apparatus) }
      let(:apparatus2) { build(:exporter_apparatus) }
      let(:contents) { [apparatus1, apparatus2] }

      it 'returns combined :to_export results of given apparatuses inside paragraph tags' do
        expect(resource.to_export).to eq("{\\par #{apparatus1.to_export}#{apparatus2.to_export} \\par}")
      end
    end
  end
end
