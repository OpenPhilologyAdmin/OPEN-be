# frozen_string_literal: true

module TokensManager
  class Resizer
    class Preparer
      def initialize(selected_text:, selected_tokens:, project:, tokens_with_offsets:)
        @selected_text                      = selected_text
        @selected_tokens                    = selected_tokens
        @project                            = project
        @tokens_with_offsets = tokens_with_offsets

        values = Preparers::BeforeAndAfterSelectionValues.new(tokens: selected_tokens, tokens_with_offsets:)
        @value_before_selected_text = values.before_selection_value
        @value_after_selected_text = values.after_selection_value
      end

      def self.perform(selected_text:, selected_tokens:, project:, tokens_with_offsets:)
        new(selected_text:, selected_tokens:, project:, tokens_with_offsets:).perform
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
        Preparers::TokenSurroundedBySubstrings.perform(
          token:        source_token,
          value_before: values.value_before,
          value_after:  values.value_after
        )
      end
    end
  end
end
