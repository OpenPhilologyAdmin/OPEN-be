# frozen_string_literal: true

module Exporter
  module Models
    class Apparatus < ExportableItem
      COLOR_SIGNIFICANT_VARIANTS = 'cf1'
      COLOR_INSIGNIFICANT_VARIANTS = 'cf2'

      def initialize(selected_variant:, secondary_variants:, insignificant_variants:,
                     apparatus_options:, apparatus_entry_index: nil)
        @apparatus_options      = apparatus_options
        @apparatus_entry_index  = apparatus_entry_index

        @selected_reading = SelectedReading.new(
          selected_variant:,
          separator:        apparatus_options_selected_reading_separator
        )
        @secondary_readings = AdditionalReadings.new(
          grouped_variants: secondary_variants,
          separator:        apparatus_options_readings_separator,
          sigla_separator:  apparatus_options_sigla_separator
        ).reading
        @insignificant_readings = AdditionalReadings.new(
          grouped_variants: insignificant_variants,
          separator:        apparatus_options_readings_separator,
          sigla_separator:  apparatus_options_sigla_separator
        ).reading

        super
      end

      def to_export
        return unless content?

        value
      end

      def content?
        significant_readings? || insignificant_readings?
      end

      private

      attr_reader :selected_reading, :secondary_readings, :insignificant_readings,
                  :apparatus_options, :apparatus_entry_index

      delegate :significant_readings?, to: :apparatus_options, prefix: true
      delegate :insignificant_readings?, to: :apparatus_options, prefix: true
      delegate :selected_reading_separator, to: :apparatus_options, prefix: true
      delegate :readings_separator, to: :apparatus_options, prefix: true
      delegate :sigla_separator, to: :apparatus_options, prefix: true
      delegate :include_apparatus?, to: :apparatus_options, prefix: true
      delegate :footnote_numbering?, to: :apparatus_options, prefix: true

      def apparatus_index
        return unless apparatus_options_footnote_numbering?
        return if apparatus_entry_index.blank?

        "(#{apparatus_entry_index})"
      end

      def styled_selected_reading
        "#{to_style(style: :bold, given_value: selected_reading_with_index)} #{selected_reading.witnesses}"
      end

      def selected_reading_with_index
        @selected_reading_with_index ||= [apparatus_index, selected_reading.reading].compact.join(' ')
      end

      def styled_line_with_readings(readings:, color:, include_line_break: false)
        to_style(
          style:       :indented_line,
          given_value: colored_text(value: readings_line(readings), color:),
          options:     { include_line_break: }
        )
      end

      def colored_text(value:, color:)
        to_style(
          style:       :color,
          given_value: value,
          options:     { color: }
        )
      end

      def readings_line(readings)
        [styled_selected_reading, readings].join("#{apparatus_options_readings_separator} ")
      end

      def significant_readings?
        apparatus_options_significant_readings? && secondary_readings.present?
      end

      def insignificant_readings?
        apparatus_options_insignificant_readings? && insignificant_readings.present?
      end

      def significant_and_insignificant_readings?
        significant_readings? && insignificant_readings?
      end

      def value
        value = ''
        if significant_readings?
          value += styled_line_with_readings(
            readings:           secondary_readings,
            color:              COLOR_SIGNIFICANT_VARIANTS,
            include_line_break: significant_and_insignificant_readings?
          )
        end
        if insignificant_readings?
          value += styled_line_with_readings(
            readings: insignificant_readings,
            color:    COLOR_INSIGNIFICANT_VARIANTS
          )
        end
        value
      end
    end
  end
end
