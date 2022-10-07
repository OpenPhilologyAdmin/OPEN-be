# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TokensManager::Resizer::Preparers::ValueBeforeAndAfterAdder, type: :service do
  let(:token) { build(:token, :variant_selected_and_secondary) }
  let(:service) { described_class.new(token:, value_before:, value_after:) }

  describe '#perform' do
    before { service.perform }

    context 'when there is only the value_before given' do
      let(:value_before) { Faker::Lorem.word }
      let(:value_after) { nil }

      it 'adds the value_before at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_before at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_before at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(value_before)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end

    context 'when there is only the value_after given' do
      let(:value_before) { nil }
      let(:value_after) {  Faker::Lorem.word }

      it 'adds the value_after at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_after at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_after at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(value_after)
      end

      context 'when there is no editorial_remark' do
        let(:token) { build(:token, :variant_selected_and_secondary, :without_editorial_remark) }

        it 'leaves editorial remark nil' do
          expect(token.editorial_remark).to be_nil
        end
      end
    end

    context 'when there are both value_before and value_after given' do
      let(:value_before) { Faker::Lorem.word }
      let(:value_after) { Faker::Lorem.word }

      it 'adds the value_before at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_after at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_before at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_after at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_before at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(value_before)
      end

      it 'adds the value_after at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(value_after)
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
      let(:value_before) { Faker::Lorem.word }
      let(:value_after) { Faker::Lorem.word }
      let(:service) do
        described_class.new(token:, value_before: "#{value_before}#{placeholder}",
                            value_after: "#{value_after}#{placeholder}")
      end

      it 'adds the value_before without placeholders at the beginning of variants' do
        token.variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_after without placeholders at the end of variants' do
        token.variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_before without placeholders at the beginning of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to start_with(value_before)
        end
      end

      it 'adds the value_after without placeholders at the end of grouped_variants' do
        token.grouped_variants.each do |variant|
          expect(variant.t).to end_with(value_after)
        end
      end

      it 'adds the value_before without placeholders at the beginning of the editorial remark' do
        expect(token.editorial_remark.t).to start_with(value_before)
      end

      it 'adds the value_after without placeholders at the end of the editorial remark' do
        expect(token.editorial_remark.t).to end_with(value_after)
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
