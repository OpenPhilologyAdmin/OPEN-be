# frozen_string_literal: true

module Exporter
  module Models
    class AdditionalReadings
      include ::Apparatus::Concerns::FormattableReading

      def initialize(grouped_variants:, separator:, sigla_separator:)
        @grouped_variants = grouped_variants
        @separator = separator
        @sigla_separator = sigla_separator
      end

      def reading
        readings.sort.join("#{separator} ")
      end

      private

      attr_reader :grouped_variants, :separator, :sigla_separator

      def readings
        grouped_variants.map do |variant|
          full_reading_for(variant:, sigla_separator:)
        end
      end
    end
  end
end
