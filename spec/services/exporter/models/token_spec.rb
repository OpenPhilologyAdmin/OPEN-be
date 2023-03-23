# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exporter::Models::Token, type: :model do
  describe '#to_export' do
    let(:resource) { described_class.new(value:, footnote_numbering:, apparatus_entry_index:) }
    let(:value) { Faker::Lorem.sentence }
    let(:apparatus_entry_index) { Faker::Number.digit }

    context 'when footnote_numbering disabled' do
      let(:footnote_numbering) { false }

      it 'returns the value without index' do
        expect(resource.to_export).to eq(value)
      end
    end

    context 'when footnote_numbering enabled' do
      let(:footnote_numbering) { true }

      context 'when apparatus_entry_index given' do
        context 'when the value ends with space' do
          let(:value) { ' lorem ipsum ' }

          it 'returns the value with trailing space removed and index wrapped by brackets and the RTF subscript tag' do
            expect(resource.to_export).to eq(" lorem ipsum{\\super (#{apparatus_entry_index})} ")
          end
        end

        context 'when the value does not end with space' do
          it 'returns the value with index wrapped by brackets and the RTF subscript tag' do
            expect(resource.to_export).to eq("#{value}{\\super (#{apparatus_entry_index})} ")
          end
        end
      end

      context 'when apparatus_entry_index not given' do
        let(:apparatus_entry_index) { nil }

        it 'returns the value without index' do
          expect(resource.to_export).to eq(value)
        end
      end
    end
  end
end
