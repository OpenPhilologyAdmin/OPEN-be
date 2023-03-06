# frozen_string_literal: true

module Apparatus
  module Concerns
    module FormattableReading
      extend ActiveSupport::Concern
      DEFAULT_SIGLA_SEPARATOR = ':'

      def full_reading_for(variant:, sigla_separator: DEFAULT_SIGLA_SEPARATOR)
        ReadingsPreparer.new(
          variant:,
          sigla_separator:
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
        def initialize(variant:, separator: nil, sigla_separator: nil)
          @variant   = variant
          @separator = separator
          @sigla_separator = sigla_separator
        end

        def full_reading
          "#{witnesses}#{sigla_separator} #{base_reading}".strip
        end

        def base_reading
          @base_reading ||= "#{variant_formatted_value} #{separator}"
        end

        def witnesses
          @witnesses ||= variant_formatted_witnesses
        end

        private

        attr_reader :variant, :separator, :sigla_separator

        delegate :formatted_value, to: :variant, prefix: true
        delegate :formatted_witnesses, to: :variant, prefix: true
      end
    end
  end
end
