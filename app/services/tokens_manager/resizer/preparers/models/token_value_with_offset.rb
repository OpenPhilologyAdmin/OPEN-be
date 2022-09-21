# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      module Models
        class TokenValueWithOffset
          attr_reader :token_index, :offset

          def initialize(offset:, token:)
            @offset = offset
            @token_index = token.index
            @token_value = token.t
          end

          def before_offset_value
            token_value[0...offset]
          end

          def after_offset_value
            token_value[offset..]
          end

          private

          attr_reader :token_value
        end
      end
    end
  end
end
