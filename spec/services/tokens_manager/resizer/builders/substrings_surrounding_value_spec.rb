# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Builders::SubstringsSurroundingValue, type: :model do
  let(:substrings) { Faker::Lorem.words(number: 3) }
  let(:base_string) { substrings.join }
  let(:service) { described_class.new(base_string:, value:) }

  describe '#perform' do
    let(:result) { service.perform }
    let(:substring_before) { result.first }
    let(:substring_after) { result.last }

    describe '#substring_before' do
      context 'when there was a text before the given substring' do
        let(:value) { substrings.second }

        it 'is returns the substring before the selection' do
          expect(substring_before).to eq(substrings.first)
        end
      end

      context 'when there was no text before the given substring' do
        let(:value) { substrings.first + substrings.second }

        it 'is blank' do
          expect(substring_before).to be_blank
        end
      end
    end

    describe '#substring_after' do
      context 'when there was a text after the given substring' do
        let(:value) { substrings.second }

        it 'is returns the substring after the selection' do
          expect(substring_after).to eq(substrings.last)
        end
      end

      context 'when there was no text after the given substring' do
        let(:value) { substrings.second + substrings.last }

        it 'is blank' do
          expect(substring_after).to be_blank
        end
      end
    end
  end
end
