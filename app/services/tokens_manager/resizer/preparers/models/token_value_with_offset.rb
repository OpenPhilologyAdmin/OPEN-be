# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Models
        class TokenValueWithOffset
          include TokensManager::Resizer::Preparers::Concerns::WithOffsets

          attr_reader :token_index, :offset

          def initialize(token:, offset:)
            @token_index = token.index
            @token_value = token.t
            @offset = offset
          end

          def value_before
            value_before_offset(given_value: token_value, given_offset: offset)
          end

          def value_after
            value_after_offset(given_value: token_value, given_offset: offset)
          end

          private

          attr_reader :token_value
        end
      end
    end
  end
end
