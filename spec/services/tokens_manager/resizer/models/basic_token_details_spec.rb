# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Models::BasicTokenDetails, type: :model do
  let(:value) { Faker::Lorem.sentence }
  let(:witnesses_ids) { %w[A B C] }
  let(:record) { described_class.new(value:, witnesses_ids:) }

  describe '#variants' do
    context 'when the given value does not include placeholders' do
      it 'builds variants with the given value' do
        record.variants.each do |variant|
          expect(variant.t).to eq(value)
        end
      end

      it 'builds variants for the given witnesses IDs' do
        expect(record.variants.size).to eq(witnesses_ids.size)
        record.variants.each do |variant|
          expect(witnesses_ids).to include(variant.witness)
        end
      end
    end

    context 'when the given value does include placeholders' do
      let(:placeholder) { TokensManager::Resizer::Models::Concerns::Placeholderable::PLACEHOLDER }
      let(:value) { "Lorem #{placeholder} ipsum#{placeholder}" }
      let(:expected_t) { 'Lorem  ipsum' }

      it 'builds variants with the given value without placeholders' do
        record.variants.each do |variant|
          expect(variant.t).to eq(expected_t)
        end
      end

      it 'builds variants for the given witnesses IDs' do
        expect(record.variants.size).to eq(witnesses_ids.size)
        record.variants.each do |variant|
          expect(witnesses_ids).to include(variant.witness)
        end
      end
    end
  end

  describe '#grouped_variants' do
    it 'calculates the grouped variants' do
      expect(record.grouped_variants).to eq(generate_grouped_variants(token: record))
    end
  end

  describe '#editorial_remark' do
    it 'is always nil' do
      expect(record.editorial_remark).to be_nil
    end
  end
end
