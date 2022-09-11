# frozen_string_literal: true

module TokensManager
  class Resizer
    module Builders
      module Concerns
        module WithoutPlaceholders
          PLACEHOLDER = FormattableT::EMPTY_VALUE_PLACEHOLDER
          extend ActiveSupport::Concern

          private

          def without_placeholders(value)
            value = value.tr(PLACEHOLDER, '')
            value.empty? ? nil : value
          end
        end
      end
    end
  end
end
