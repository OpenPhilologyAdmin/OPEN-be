# frozen_string_literal: true

require 'rails_helper'
require 'support/helpers/apparatus_export'

RSpec.configure do |c|
  c.include Helpers::ApparatusExport
end

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Exporter::Models::Apparatus, type: :model do
  describe '#to_export' do
    let(:resource) do
      described_class.new(
        selected_variant:,
        secondary_variants:,
        insignificant_variants:,
        apparatus_options:
      )
    end
    let(:selected_variant) { build(:token_grouped_variant, :selected) }
    let(:secondary_variants) { build_list(:token_grouped_variant, 2, :secondary) }
    let(:insignificant_variants) { build_list(:token_grouped_variant, 2, :insignificant) }
    let(:apparatus_options) { build(:apparatus_options) }
    let(:significant_variants_line_options) { { include_line_break: true } }
    let(:significant_variants_line) do
      within_indented_line(value:
                                    with_color(
                                      value: [
                                        formatted_selected_reading, formatted_secondary_variants
                                      ].join("#{apparatus_options.readings_separator} "),
                                      color: described_class::COLOR_SIGNIFICANT_VARIANTS
                                    ),
                           options: significant_variants_line_options)
    end
    let(:insignificant_variants_line) do
      within_indented_line(value:
                                  with_color(
                                    value: [
                                      formatted_selected_reading, formatted_insignificant_variants
                                    ].join("#{apparatus_options.readings_separator} "),
                                    color: described_class::COLOR_INSIGNIFICANT_VARIANTS
                                  ))
    end

    let(:formatted_selected_reading) do
      selected_grouped_variant_to_export(
        grouped_variant: selected_variant,
        separator:       apparatus_options.selected_reading_separator,
        open_tag:        '{\\b',
        close_tag:       '}'
      )
    end
    let(:formatted_secondary_variants) do
      grouped_variants_to_export(
        grouped_variants: secondary_variants,
        separator:        apparatus_options.readings_separator,
        sigla_separator:  apparatus_options.sigla_separator
      )
    end
    let(:formatted_insignificant_variants) do
      grouped_variants_to_export(
        grouped_variants: insignificant_variants,
        separator:        apparatus_options.readings_separator,
        sigla_separator:  apparatus_options.sigla_separator
      )
    end

    context 'when significant_readings: true and insignificant_readings: true' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: true, insignificant_readings: true)
      end

      let(:expected_value) do
        significant_variants_line + insignificant_variants_line
      end

      context 'when token has both secondary and insignificant readings' do
        it 'returns significant and insignificant variants as two indented lines' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected and secondary readings' do
        let(:insignificant_variants) { [] }
        let(:significant_variants_line_options) { { include_line_break: false } }
        let(:expected_value) do
          significant_variants_line
        end

        it 'returns significant variants as one indented line' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected and insignificant readings' do
        let(:secondary_variants) { [] }
        let(:expected_value) do
          insignificant_variants_line
        end

        it 'returns insignificant variants as one indented line' do
          expect(resource.to_export).to eq(expected_value)
        end
      end

      context 'when token has only selected reading' do
        let(:secondary_variants) { [] }
        let(:insignificant_variants) { [] }

        it 'returns nil, as there is no apparatus to display' do
          expect(resource.to_export).to be_nil
        end
      end
    end

    context 'when significant_readings: true and insignificant_readings: false' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: true, insignificant_readings: false)
      end

      let(:significant_variants_line_options) { { include_line_break: false } }

      let(:expected_value) do
        significant_variants_line
      end

      it 'returns significant variants as one indented line' do
        expect(resource.to_export).to eq(expected_value)
      end
    end

    context 'when significant_readings: false and insignificant_readings: true' do
      let(:apparatus_options) do
        build(:apparatus_options, significant_readings: false, insignificant_readings: true)
      end

      let(:expected_value) do
        insignificant_variants_line
      end

      it 'returns significant variants as one indented line' do
        expect(resource.to_export).to eq(expected_value)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
