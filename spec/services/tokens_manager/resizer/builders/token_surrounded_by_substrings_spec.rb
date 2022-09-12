# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Builders::TokenSurroundedBySubstrings, type: :service do
  let(:token) { build(:token, :variant_selected_and_secondary) }
  let(:base_string) { "#{substring_before}#{token.t}#{substring_after}" }
  let(:service) { described_class.new(token:, selected_text: base_string) }

  describe '#perform' do
    before { service.perform }

    context 'when there is only a substring_before given' do
      let(:substring_before) { Faker::Lorem.word }
      let(:substring_after) { nil }

      it 'adds substring_before at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_before at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_before at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(substring_before)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end

    context 'when there is only a substring_after given' do
      let(:substring_before) { nil }
      let(:substring_after) {  Faker::Lorem.word }

      it 'adds substring_after at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_after at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_after at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(substring_after)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end

    context 'when there are both substring_before and substring_after given' do
      let(:substring_before) { Faker::Lorem.word }
      let(:substring_after) { Faker::Lorem.word }

      it 'adds substring_before at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_after at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_before at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_after at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_before at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(substring_before)
      end

      it 'adds substring_after at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(substring_after)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end

    context 'when there are some placeholders' do
      let(:placeholder) { FormattableT::EMPTY_VALUE_PLACEHOLDER }
      let(:substring_before) { Faker::Lorem.word }
      let(:substring_after) { Faker::Lorem.word }
      let(:base_string) { "#{substring_before}#{placeholder}#{token.t}#{substring_after}#{placeholder}" }

      it 'adds substring_before without placeholders at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_after without placeholders at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_before without placeholders at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(substring_before)
        end
      end

      it 'adds substring_after without placeholders at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(substring_after)
        end
      end

      it 'adds substring_before without placeholders at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(substring_before)
      end

      it 'adds substring_after without placeholders at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(substring_after)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end
  end
end
