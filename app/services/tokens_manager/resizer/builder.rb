# frozen_string_literal: true

module TokensManager
  class Resizer
    class Builder
      def initialize(selected_text:, selected_tokens:, project:)
        @selected_text                      = selected_text
        @selected_tokens                    = selected_tokens
        @project                            = project
        @substring_before, @substring_after = substrings_surrounding_selected_text
      end

      def self.perform(selected_text:, selected_tokens:, project:)
        new(selected_text:, selected_tokens:, project:).perform
      end

      def perform
        [
          token_from_value(substring_before),
          token_from_source_token,
          token_from_value(substring_after)
        ].compact
      end

      private

      attr_reader :selected_text, :selected_tokens, :project,
                  :substring_before, :substring_after

      def substrings_surrounding_selected_text
        TokensManager::Resizer::Builders::SubstringsSurroundingValue.perform(
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

        Builders::TokenFromValue.perform(value:, project:)
      end

      def token_from_source_token
        return token_from_value(selected_text) if source_token.blank?

        Builders::TokenSurroundedBySubstrings.perform(token: source_token, selected_text:)
      end
    end
  end
end
