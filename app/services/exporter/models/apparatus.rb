# frozen_string_literal: true

module Exporter
  module Models
    class Apparatus < ExportableItem
      def initialize(selected_variant:, secondary_variants:, insignificant_variants:,
                     apparatus_options:, index:)
        @selected_variant       = selected_variant
        @secondary_variants     = secondary_variants
        @insignificant_variants = insignificant_variants
        @apparatus_options      = apparatus_options
        @index                  = index
        super
      end

      def to_export
        return unless apparatus_options_include_apparatus?

        "(#{index}) #{readings.join(', ')}#{apparatus_options_entries_separator} "
      end

      private

      attr_reader :selected_variant, :secondary_variants, :insignificant_variants,
                  :index, :apparatus_options

      delegate :significant_readings?, to: :apparatus_options, prefix: true
      delegate :insignificant_readings?, to: :apparatus_options, prefix: true
      delegate :selected_reading_separator, to: :apparatus_options, prefix: true
      delegate :secondary_readings_separator, to: :apparatus_options, prefix: true
      delegate :insignificant_readings_separator, to: :apparatus_options, prefix: true
      delegate :entries_separator, to: :apparatus_options, prefix: true
      delegate :include_apparatus?, to: :apparatus_options, prefix: true

      def readings
        values = []
        values += significant_readings if apparatus_options_significant_readings?
        values << insignificant_readings if apparatus_options_insignificant_readings?
        values.compact_blank!
      end

      def significant_readings
        [styled_selected_reading, secondary_readings]
      end

      def styled_selected_reading
        "#{to_style(style: :bold, given_value: selected_reading.reading)} #{selected_reading.witnesses}"
      end

      def selected_reading
        @selected_reading ||= SelectedReading.new(
          selected_variant:,
          separator:        apparatus_options_selected_reading_separator
        )
      end

      def secondary_readings
        @secondary_readings ||= AdditionalReadings.new(
          grouped_variants: secondary_variants,
          separator:        apparatus_options_secondary_readings_separator
        ).reading
      end

      def insignificant_readings
        @insignificant_readings ||= AdditionalReadings.new(
          grouped_variants: insignificant_variants,
          separator:        apparatus_options_insignificant_readings_separator
        ).reading
      end
    end
  end
end
