# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Concerns
        module WithSurroundingValues
          extend ActiveSupport::Concern

          private

          def with_surrounding_values(value:, value_before: nil, value_after: nil)
            "#{value_before}#{value}#{value_after}"
          end
        end
      end
    end
  end
end
