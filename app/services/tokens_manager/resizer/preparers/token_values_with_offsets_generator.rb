# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenValuesWithOffsetsGenerator
        def initialize(tokens:, tokens_with_offsets:)
          @tokens = tokens
          @tokens_with_offsets = tokens_with_offsets
        end

        def self.perform(tokens:, tokens_with_offsets:)
          new(tokens:, tokens_with_offsets:).perform
        end

        def perform
          sorted_token_values_with_offsets
        end

        private

        attr_reader :tokens, :tokens_with_offsets

        def token_values_with_offsets
          @token_values_with_offsets ||= tokens_with_offsets.map do |token_with_offset_attrs|
            build_token_value_with_offset(token_with_offset_attrs)
          end
        end

        def build_token_value_with_offset(token_with_offset_attrs)
          token = find_token(token_with_offset_attrs[:token_id])
          Models::TokenValueWithOffset.new(
            token:,
            offset: token_with_offset_attrs[:offset]
          )
        end

        def find_token(token_id)
          tokens.find { |token| token.id == token_id }
        end

        def sorted_token_values_with_offsets
          token_values_with_offsets.sort_by { |record| [record.token_index, record.offset] }
        end
      end
    end
  end
end
