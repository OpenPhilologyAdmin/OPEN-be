# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class ValueBeforeAndAfterTokenCalculator
        def initialize(token:, selected_tokens:, value_before_selected_text:, selected_text:)
          @token                     = token
          @selected_text             = selected_text
          @distance_before_selected_text = value_before_selected_text.size
          @distance_between_token_and_beginning_of_text = length_of_preceding_text(selected_tokens)
        end

        def self.perform(token:, selected_tokens:, value_before_selected_text:, selected_text:)
          new(selected_tokens:, value_before_selected_text:, token:, selected_text:).perform
        end

        def perform
          Models::ValueWithOffsets.new(
            value:           selected_text,
            starting_offset: token_starting_offset,
            ending_offset:   token_ending_offset
          )
        end

        private

        attr_accessor :token, :selected_text,
                      :distance_before_selected_text, :distance_between_token_and_beginning_of_text

        def length_of_preceding_text(all_tokens)
          preceding_tokens = all_tokens.select { |preceding_token| preceding_token.index < token.index }
          preceding_tokens.map(&:t).join.size
        end

        def token_starting_offset
          @token_starting_offset ||= distance_between_token_and_beginning_of_text - distance_before_selected_text
        end

        def token_ending_offset
          @token_ending_offset ||= token_starting_offset + token.t.size
        end
      end
    end
  end
end
