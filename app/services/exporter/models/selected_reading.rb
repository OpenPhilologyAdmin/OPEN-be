# frozen_string_literal: true

module Exporter
  module Models
    class SelectedReading
      include ::Apparatus::Concerns::FormattableReading

      def initialize(selected_variant:, separator:)
        @selected_variant = selected_variant
        @separator        = separator
      end

      def reading
        base_reading_for(variant:   selected_variant,
                         separator:)
      end

      def witnesses
        witnesses_for(variant: selected_variant)
      end

      private

      attr_accessor :selected_variant, :separator
    end
  end
end
