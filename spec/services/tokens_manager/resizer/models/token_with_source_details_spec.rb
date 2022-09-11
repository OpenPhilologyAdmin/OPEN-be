# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/token_variants'

RSpec.configure do |c|
  c.include Helpers::TokenVariants
end

RSpec.describe TokensManager::Resizer::Models::TokenWithSourceDetails, type: :model do
  let(:source_token) { build(:token, :variant_selected_and_secondary) }
  let(:substring_before) { Faker::Lorem.word }
  let(:substring_after) { Faker::Lorem.word }
  let(:base_string) { "#{substring_before}#{source_token.t}#{substring_after}" }
  let(:record) { described_class.new(base_string:, source_token:) }
  let(:placeholder) { TokensManager::Resizer::Models::ProcessedString::PLACEHOLDER }

  describe '#variants' do
    context 'when the value does not include placeholders' do
      it 'builds t for variants using the variants of the source token and the substrings' do
        record.variants.each do |variant|
          source_variant = find_variant(variants: source_token.variants, witness: variant.witness)
          expect(variant.t).to eq("#{substring_before}#{source_variant.t}#{substring_after}")
        end
      end

      it 'builds the same number of variants as the source_token has' do
        expect(record.variants.size).to eq(source_token.variants.size)
      end
    end

    context 'when the given value include placeholders' do
      let(:substring_before) { "#{Faker::Lorem.word}#{placeholder}" }
      let(:substring_after) { "#{placeholder}#{Faker::Lorem.word}" }

      it 'build variants using variants of the source token and the substrings ignoring placeholders' do
        record.variants.each do |variant|
          source_variant = find_variant(variants: source_token.variants, witness: variant.witness)
          expected_value = "#{substring_before}#{source_variant.t}#{substring_after}".tr(placeholder, '')
          expect(variant.t).to eq(expected_value)
        end
      end

      it 'builds the same number of variants as the source_token has' do
        expect(record.variants.size).to eq(source_token.variants.size)
      end
    end
  end

  describe '#grouped_variants' do
    context 'when the source token did not have any selections' do
      let(:source_token) { build(:token) }

      it 'calculates the grouped variants without selections' do
        expect(record.grouped_variants).to eq(generate_grouped_variants(token: record))
      end
    end

    context 'when the source token had some selections' do
      let(:source_token) { build(:token) }

      it 'calculates the grouped variants and preserve selections' do
        expected_grouped_variants = source_token.grouped_variants.deep_dup
        expected_grouped_variants.each do |resource|
          resource.t = TokensManager::Resizer::Models::ProcessedString.new(string: resource.t, substring_before:,
                                                                           substring_after:).string
        end
        expect(record.grouped_variants).to eq(expected_grouped_variants)
      end
    end
  end

  describe '#editorial_remark' do
    context 'when there is no editorial_remark for the source token' do
      let(:source_token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

      it 'is nil' do
        expect(record.editorial_remark).to be_nil
      end
    end

    context 'when source token has an editorial_remark' do
      let(:source_token) { build(:token, :variant_selected_and_secondary) }
      let(:source_editorial_remark) { source_token.editorial_remark }

      it 'builds t of editorial remark using the source editorial remark for the source token and the substrings' do
        expect(record.editorial_remark.t).to eq("#{substring_before}#{source_editorial_remark.t}#{substring_after}")
      end

      it 'builds type of editorial remark using the editorial remark type' do
        expect(record.editorial_remark.type).to eq(source_editorial_remark.type)
      end

      context 'when the given value include placeholders' do
        let(:substring_before) { "#{placeholder}#{Faker::Lorem.word}" }
        let(:substring_after) { "#{Faker::Lorem.word}#{placeholder}" }

        it 'builds t of the editorial remark without the placeholders' do
          expected_value = "#{substring_before}#{source_editorial_remark.t}#{substring_after}".tr(placeholder, '')

          expect(record.editorial_remark.t).to eq(expected_value)
        end
      end
    end
  end
end
