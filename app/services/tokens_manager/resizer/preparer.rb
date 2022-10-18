# frozen_string_literal: true

module TokensManager
  class Resizer
    class Preparer
      def initialize(params:)
        @params = params
      end

      def self.perform(params:)
        new(params:).perform
      end

      def perform
        [
          token_from_value(value_before_selected_text),
          token_from_selected_text,
          token_from_value(value_after_selected_text)
        ].compact
      end

      private

      attr_reader :params

      delegate :project, :selected_text, :selected_tokens,
               :tokens_with_offsets, :selected_multiple_readings_token,
               to: :params

      def values_before_and_after_selected_text
        @values_before_and_after_selected_text ||= Preparers::ValueBeforeAndAfterSelectedTextCalculator.new(
          tokens:              selected_tokens,
          tokens_with_offsets:
        )
      end

      def value_before_selected_text
        @value_before_selected_text ||= values_before_and_after_selected_text.value_before
      end

      def value_after_selected_text
        @value_after_selected_text ||= values_before_and_after_selected_text.value_after
      end

      def token_from_value(value)
        return if value.blank?

        Preparers::TokenFromValue.perform(value:, project:)
      end

      def token_from_selected_text
        if selected_multiple_readings_token.blank?
          Preparers::TokenFromValue.perform(
            value:   selected_text,
            project:,
            resized: true
          )
        else
          Preparers::TokenFromMultipleReadingsToken.perform(
            params:,
            value_before_selected_text:
          )
        end
      end
    end
  end
end
