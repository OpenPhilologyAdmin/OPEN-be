# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Concerns
        module WithOffsets
          extend ActiveSupport::Concern

          private

          def value_before_offset(given_value:, given_offset:)
            given_value[0...given_offset]
          end

          def value_after_offset(given_value:, given_offset:)
            given_value[given_offset..]
          end
        end
      end
    end
  end
end
