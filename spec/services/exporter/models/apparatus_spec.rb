# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_export'

RSpec.configure do |c|
  c.include Helpers::ApparatusExport
end

RSpec.describe Exporter::Models::Apparatus, type: :model do
  describe '#to_export' do
    let(:resource) do
      described_class.new(
        selected_variant:,
        secondary_variants:,
        insignificant_variants:,
        apparatus_options:,
        index:
      )
    end
    let(:selected_variant) { build(:token_grouped_variant, :selected) }
    let(:secondary_variants) { build_list(:token_grouped_variant, 2, :secondary) }
    let(:insignificant_variants) { build_list(:token_grouped_variant, 2, :insignificant) }
    let(:apparatus_options) { build(:apparatus_options) }
    let(:index) { Faker::Number.digit }

    context 'when significant_readings: true and insignificant_readings: true' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: true, insignificant_readings: true)
      end

      let(:expected_value) do
        "(#{index}) #{expected_selected_reading}, #{expected_secondary_variants}, " \
          "#{expected_insignificant_variants}#{apparatus_options.entries_separator} " \
      end

      let(:expected_selected_reading) do
        selected_grouped_variant_to_export(
          grouped_variant: selected_variant,
          separator:       apparatus_options.selected_reading_separator,
          open_tag:        '{\\b',
          close_tag:       '}'
        )
      end

      let(:expected_secondary_variants) do
        grouped_variants_to_export(
          grouped_variants: secondary_variants,
          separator:        apparatus_options.secondary_readings_separator
        )
      end

      let(:expected_insignificant_variants) do
        grouped_variants_to_export(
          grouped_variants: insignificant_variants,
          separator:        apparatus_options.insignificant_readings_separator
        )
      end

      context 'when token has both secondary and insignificant readings' do
        it 'returns the index, followed by bolded selected reading, secondary readings, insignificant readings ' \
           'and entries_separator' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected and secondary readings' do
        let(:insignificant_variants) { [] }
        let(:expected_value) do
          "(#{index}) #{expected_selected_reading}, #{expected_secondary_variants}" \
            "#{apparatus_options.entries_separator} " \
        end

        it 'returns the index, followed by bolded selected reading, secondary readings, ' \
           'and entries_separator' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected and insignificant readings' do
        let(:secondary_variants) { [] }
        let(:expected_value) do
          "(#{index}) #{expected_selected_reading}, " \
            "#{expected_insignificant_variants}#{apparatus_options.entries_separator} " \
        end

        it 'returns the index, followed by bolded selected reading, insignificant readings, ' \
           'and entries_separator' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected reading' do
        let(:secondary_variants) { [] }
        let(:insignificant_variants) { [] }
        let(:expected_value) do
          "(#{index}) #{expected_selected_reading}#{apparatus_options.entries_separator} "
        end

        it 'returns the index, followed by bolded selected reading and entries_separator' do
          expect(resource.to_export).to eq(expected_value)
        end
      end
    end

    context 'when significant_readings: true and insignificant_readings: false' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: true, insignificant_readings: false)
      end

      let(:expected_value) do
        "(#{index}) #{expected_selected_reading}, #{expected_secondary_variants}" \
          "#{apparatus_options.entries_separator} " \
      end

      let(:expected_selected_reading) do
        selected_grouped_variant_to_export(
          grouped_variant: selected_variant,
          separator:       apparatus_options.selected_reading_separator,
          open_tag:        '{\\b',
          close_tag:       '}'
        )
      end

      let(:expected_secondary_variants) do
        grouped_variants_to_export(
          grouped_variants: secondary_variants,
          separator:        apparatus_options.secondary_readings_separator
        )
      end

      it 'returns the index, followed by bolded selected reading, then secondary readings, and entries_separator' do
        expect(resource.to_export).to eq(expected_value)
      end
    end

    context 'when significant_readings: false and insignificant_readings: true' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: false, insignificant_readings: true)
      end

      let(:expected_value) do
        "(#{index}) #{expected_insignificant_variants}#{apparatus_options.entries_separator} " \
      end

      let(:expected_insignificant_variants) do
        grouped_variants_to_export(
          grouped_variants: insignificant_variants,
          separator:        apparatus_options.insignificant_readings_separator
        )
      end

      it 'returns the index, followed by insignificant readings and entries_separator' do
        expect(resource.to_export).to eq(expected_value)
      end
    end

    context 'when significant_readings: false and insignificant_readings: false' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: false, insignificant_readings: false)
      end

      it 'returns nil' do
        expect(resource.to_export).to be_nil
      end
    end
  end
end
