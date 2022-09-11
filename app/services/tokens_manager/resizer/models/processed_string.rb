# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class ProcessedString
        PLACEHOLDER = FormattableT::EMPTY_VALUE_PLACEHOLDER
        attr_reader :string

        def initialize(string:, substring_before: nil, substring_after: nil)
          @string = without_placeholders("#{substring_before}#{string}#{substring_after}")
        end

        private

        def without_placeholders(value)
          value = value.tr(PLACEHOLDER, '')
          value.empty? ? nil : value
        end
      end
    end
  end
end
