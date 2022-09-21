# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenValuesWithOffsets
        def initialize(tokens:, tokens_with_offsets:)
          @tokens = tokens
          @token_values_with_offsets = tokens_with_offsets.map do |token_with_offset_attrs|
            build_token_value_with_offset(token_with_offset_attrs)
          end
        end

        def self.perform(tokens:, tokens_with_offsets:)
          new(tokens:, tokens_with_offsets:).perform
        end

        def perform
          sort_token_values_with_offsets
        end

        private

        attr_reader :token_values_with_offsets, :tokens, :sort_param

        def build_token_value_with_offset(token_with_offset_attrs)
          token = find_token(token_with_offset_attrs[:token_id])
          Models::TokenValueWithOffset.new(offset: token_with_offset_attrs[:offset], token:)
        end

        def find_token(token_id)
          tokens.find { |token| token.id == token_id }
        end

        def sort_token_values_with_offsets
          token_values_with_offsets.sort_by { |record| [record.token_index, record.offset] }
        end
      end
    end
  end
end
