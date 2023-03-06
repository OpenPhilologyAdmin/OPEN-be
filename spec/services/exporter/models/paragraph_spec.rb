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
        expect(resource.to_export).to eq("{\\pard\\sl360\\slmult1\n\n\\par}\n")
      end
    end

    context 'when contents include tokens' do
      let(:token1) { build(:exporter_token) }
      let(:token2) { build(:exporter_token) }
      let(:contents) { [token1, token2] }

      it 'returns combined :to_export results of given tokens inside paragraph tags' do
        expect(resource.to_export).to eq("{\\pard\\sl360\\slmult1\n#{token1.to_export}#{token2.to_export}\n\\par}\n")
      end
    end

    context 'when contents include apparatuses' do
      let(:apparatus1) { build(:exporter_apparatus) }
      let(:apparatus2) { build(:exporter_apparatus) }
      let(:contents) { [apparatus1, apparatus2] }

      it 'returns combined :to_export results of given apparatuses inside paragraph tags' do
        expect(resource.to_export)
          .to eq("{\\pard\\sl360\\slmult1\n#{apparatus1.to_export}#{apparatus2.to_export}\n\\par}\n")
      end
    end
  end

  describe '#empty?' do
    let(:resource) do
      described_class.new(
        contents:
      )
    end

    context 'when contents empty' do
      let(:contents) { [] }

      it 'returns true' do
        expect(resource).to be_empty
      end
    end

    context 'when contents include tokens' do
      let(:token) { build(:exporter_token) }
      let(:contents) { [token] }

      it 'returns false' do
        expect(resource).not_to be_empty
      end
    end
  end

  describe '#push' do
    let(:initial_element) { 'lorem' }
    let(:resource) do
      described_class.new(
        contents: [initial_element]
      )
    end
    let(:new_element) { 'ipsum' }

    before { resource.push(new_element) }

    it 'adds the given element at the end of contents array' do
      expect(resource.contents.last).to eq(new_element)
    end

    it 'preserves the elements that were in contents array previously' do
      expect(resource.contents.size).to eq(2)
      expect(resource.contents.first).to eq(initial_element)
    end
  end
end
