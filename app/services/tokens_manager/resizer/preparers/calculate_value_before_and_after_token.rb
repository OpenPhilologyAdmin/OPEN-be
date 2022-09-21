# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class CalculateValueBeforeAndAfterToken
        def initialize(token:, tokens:, value_before_selected_text:, selected_text:)
          @token                     = token
          @selected_text             = selected_text
          @distance_before_selected_text = value_before_selected_text.size
          @distance_between_token_and_beginning_of_text = length_of_preceding_text(tokens)
        end

        def self.perform(token:, tokens:, value_before_selected_text:, selected_text:)
          new(tokens:, value_before_selected_text:, token:, selected_text:).perform
        end

        def perform
          token_starting_offset = distance_between_token_and_beginning_of_text - distance_before_selected_text
          token_ending_offset   = token_starting_offset + token.t.size

          Models::ValueWithOffsets.new(
            starting_offset: token_starting_offset,
            ending_offset:   token_ending_offset,
            value:           selected_text
          )
        end

        private

        attr_accessor :token, :selected_text,
                      :distance_before_selected_text, :distance_between_token_and_beginning_of_text

        def length_of_preceding_text(all_tokens)
          preceding_tokens = all_tokens.select { |preceding_token| preceding_token.index < token.index }
          preceding_tokens.map(&:t).join.size
        end
      end
    end
  end
end
