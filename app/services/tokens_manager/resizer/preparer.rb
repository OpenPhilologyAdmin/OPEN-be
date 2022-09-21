# frozen_string_literal: true

module TokensManager
  class Resizer
    class Preparer
      def initialize(selected_text:, selected_tokens:, project:)
        @selected_text                      = selected_text
        @selected_tokens                    = selected_tokens
        @project                            = project
        @value_before_selected_text, @value_after_selected_text = substrings_surrounding_selected_text
      end

      def self.perform(selected_text:, selected_tokens:, project:)
        new(selected_text:, selected_tokens:, project:).perform
      end

      def perform
        [
          token_from_value(value_before_selected_text),
          token_from_source_token,
          token_from_value(value_after_selected_text)
        ].compact
      end

      private

      attr_reader :selected_text, :selected_tokens, :project,
                  :value_before_selected_text, :value_after_selected_text

      def substrings_surrounding_selected_text
        TokensManager::Resizer::Preparers::SubstringsSurroundingValue.perform(
          base_string: selected_tokens_text,
          value:       selected_text
        )
      end

      # selected token that has multiple grouped variants
      def source_token
        @source_token ||= selected_tokens.detect { |token| !token.one_grouped_variant? }
      end

      def selected_tokens_text
        @selected_tokens_text ||= selected_tokens.map(&:t).join
      end

      def token_from_value(value)
        return if value.blank?

        Preparers::TokenFromValue.perform(value:, project:)
      end

      def token_from_source_token
        return token_from_value(selected_text) if source_token.blank?

        values = TokensManager::Resizer::Preparers::CalculateValueBeforeAndAfterToken.perform(
          token:                      source_token,
          tokens:                     selected_tokens,
          value_before_selected_text:,
          selected_text:
        )
        Preparers::TokenSurroundedBySubstrings.perform(token: source_token, value_before: values.value_before,
                                                       value_after: values.value_after)
      end
    end
  end
end
