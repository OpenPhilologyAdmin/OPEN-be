# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenFromMultipleReadingsToken
        def initialize(params:, value_before_selected_text:)
          @params = params
          @token = selected_multiple_readings_token.dup
          @value_before_selected_text = value_before_selected_text
        end

        def self.perform(params:, value_before_selected_text:)
          new(params:, value_before_selected_text:).perform
        end

        def perform
          add_before_and_after_value
          token.resized = true
          token
        end

        private

        attr_reader :token, :params, :value_before_selected_text

        delegate :selected_tokens, :selected_text, :selected_multiple_readings_token,
                 to: :params

        def value_before_token
          @value_before_token ||= values_before_and_after_token.value_before
        end

        def value_after_token
          @value_after_token ||= values_before_and_after_token.value_after
        end

        def values_before_and_after_token
          @values_before_and_after_token ||= ValueBeforeAndAfterTokenCalculator.perform(
            token:,
            selected_tokens:,
            value_before_selected_text:,
            selected_text:
          )
        end

        def add_before_and_after_value
          ValueBeforeAndAfterAdder.perform(
            token:,
            value_before: value_before_token,
            value_after:  value_after_token
          )
        end
      end
    end
  end
end
