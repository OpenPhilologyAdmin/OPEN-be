# frozen_string_literal: true

module Apparatus
  module Concerns
    module FormattableReading
      extend ActiveSupport::Concern

      def full_reading_for(variant:)
        ReadingsPreparer.new(
          variant:
        ).full_reading
      end

      def witnesses_for(variant:)
        ReadingsPreparer.new(
          variant:
        ).witnesses
      end

      def base_reading_for(variant:, separator:)
        ReadingsPreparer.new(
          variant:,
          separator:
        ).base_reading
      end

      class ReadingsPreparer
        def initialize(variant:, separator: nil)
          @variant   = variant
          @separator = separator
        end

        def full_reading
          "#{base_reading} #{witnesses}"
        end

        def base_reading
          @base_reading ||= "#{variant_formatted_value}#{separator}"
        end

        def witnesses
          @witnesses ||= variant_formatted_witnesses
        end

        private

        attr_reader :variant, :separator

        delegate :formatted_value, to: :variant, prefix: true
        delegate :formatted_witnesses, to: :variant, prefix: true
      end
    end
  end
end
