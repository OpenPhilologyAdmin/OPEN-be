# frozen_string_literal: true

module Exporter
  module Models
    class Apparatus < ExportableItem
      COLOR_SIGNIFICANT_VARIANTS = 'cf1'
      COLOR_INSIGNIFICANT_VARIANTS = 'cf2'

      def initialize(selected_variant:, secondary_variants:, insignificant_variants:, apparatus_options:)
        @selected_variant       = selected_variant
        @secondary_variants     = secondary_variants
        @insignificant_variants = insignificant_variants
        @apparatus_options      = apparatus_options
        super
      end

      def to_export
        return if apparatus_empty?

        value
      end

      private

      attr_reader :selected_variant, :secondary_variants, :insignificant_variants,
                  :apparatus_options

      delegate :significant_readings?, to: :apparatus_options, prefix: true
      delegate :insignificant_readings?, to: :apparatus_options, prefix: true
      delegate :selected_reading_separator, to: :apparatus_options, prefix: true
      delegate :readings_separator, to: :apparatus_options, prefix: true
      delegate :sigla_separator, to: :apparatus_options, prefix: true
      delegate :include_apparatus?, to: :apparatus_options, prefix: true

      def selected_reading
        @selected_reading ||= SelectedReading.new(
          selected_variant:,
          separator:        apparatus_options_selected_reading_separator
        )
      end

      def secondary_significant_readings
        @secondary_significant_readings ||= AdditionalReadings.new(
          grouped_variants: secondary_variants,
          separator:        apparatus_options_readings_separator,
          sigla_separator:  apparatus_options_sigla_separator
        ).reading
      end

      def insignificant_readings
        @insignificant_readings ||= AdditionalReadings.new(
          grouped_variants: insignificant_variants,
          separator:        apparatus_options_readings_separator,
          sigla_separator:  apparatus_options_sigla_separator
        ).reading
      end

      def styled_selected_reading
        "#{to_style(style: :bold, given_value: selected_reading.reading)} #{selected_reading.witnesses}"
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

      def apparatus_empty?
        secondary_significant_readings.blank? && insignificant_readings.blank?
      end

      def include_significant_readings?
        apparatus_options_significant_readings? && secondary_significant_readings.present?
      end

      def include_insignificant_readings?
        apparatus_options_insignificant_readings? && insignificant_readings.present?
      end

      def include_significant_and_insignificant?
        include_significant_readings? && include_insignificant_readings?
      end

      def value
        value = ''
        if include_significant_readings?
          value += styled_line_with_readings(
            readings:           secondary_significant_readings,
            color:              COLOR_SIGNIFICANT_VARIANTS,
            include_line_break: include_significant_and_insignificant?
          )
        end
        if include_insignificant_readings?
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
