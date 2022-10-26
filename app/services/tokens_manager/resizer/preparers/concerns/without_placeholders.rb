# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Concerns
        module WithoutPlaceholders
          PLACEHOLDER = FormattableT::NIL_VALUE_PLACEHOLDER
          extend ActiveSupport::Concern

          private

          def without_placeholders(value:)
            value = value.tr(PLACEHOLDER, '')
            value.empty? ? nil : value
          end
        end
      end
    end
  end
end
