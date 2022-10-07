# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Models
        class ValueWithOffsets
          include TokensManager::Resizer::Preparers::Concerns::WithOffsets

          attr_reader :starting_offset, :ending_offset

          def initialize(value:, starting_offset:, ending_offset:)
            @value           = value
            @starting_offset = starting_offset
            @ending_offset   = ending_offset
          end

          def value_before
            value_before_offset(given_value: value, given_offset: starting_offset)
          end

          def value_after
            value_after_offset(given_value: value, given_offset: ending_offset)
          end

          private

          attr_reader :value
        end
      end
    end
  end
end
