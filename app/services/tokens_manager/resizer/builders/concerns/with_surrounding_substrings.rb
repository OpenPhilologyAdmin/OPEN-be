# frozen_string_literal: true

module TokensManager
  class Resizer
    module Builders
      module Concerns
        module WithSurroundingSubstrings
          extend ActiveSupport::Concern

          private

          def with_surrounding_substrings(value:, substring_before: nil, substring_after: nil)
            "#{substring_before}#{value}#{substring_after}"
          end
        end
      end
    end
  end
end
