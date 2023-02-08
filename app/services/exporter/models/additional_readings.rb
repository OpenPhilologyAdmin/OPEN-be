# frozen_string_literal: true

module Exporter
  module Models
    class AdditionalReadings
      include ::Apparatus::Concerns::FormattableReading

      def initialize(grouped_variants:, separator:)
        @grouped_variants = grouped_variants
        @separator          = separator
      end

      def reading
        readings.sort.join("#{separator} ")
      end

      private

      attr_reader :grouped_variants, :separator

      def readings
        grouped_variants.map do |variant|
          full_reading_for(variant:)
        end
      end
    end
  end
end
