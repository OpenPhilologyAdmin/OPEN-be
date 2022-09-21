# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Models
        class ValueWithOffsets
          attr_reader :starting_offset, :ending_offset

          def initialize(starting_offset:, ending_offset:, value:)
            @starting_offset = starting_offset
            @ending_offset   = ending_offset
            @value           = value
          end

          def value_before
            value[0...starting_offset]
          end

          def value_after
            value[ending_offset..]
          end

          private

          attr_reader :value
        end
      end
    end
  end
end
