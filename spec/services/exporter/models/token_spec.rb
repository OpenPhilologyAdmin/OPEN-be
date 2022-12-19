# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Token, type: :model do
  describe '#to_export' do
    let(:resource) { described_class.new(value:, footnote_numbering:, index:) }
    let(:value) { Faker::Lorem.sentence }
    let(:index) { Faker::Number.digit }

    context 'when footnote_numbering disabled' do
      let(:footnote_numbering) { false }

      it 'returns the value without index' do
        expect(resource.to_export).to eq(value)
      end
    end

    context 'when footnote_numbering enabled' do
      let(:footnote_numbering) { true }

      context 'when index given' do
        it 'returns the value with index wrapped by the RTF subscript tag' do
          expect(resource.to_export).to eq("#{value}{\\super #{index}}")
        end
      end

      context 'when index not given' do
        let(:index) { nil }

        it 'returns the value without index' do
          expect(resource.to_export).to eq(value)
        end
      end
    end
  end
end
