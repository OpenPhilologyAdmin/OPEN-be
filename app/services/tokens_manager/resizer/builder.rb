# frozen_string_literal: true

module TokensManager
  class Resizer
    class Builder
      def initialize(selected_text:, selected_tokens:, project:)
        @selected_text   = selected_text
        @selected_tokens = selected_tokens
        @project         = project
      end

      def self.perform(selected_text:, selected_tokens:, project:)
        new(selected_text:, selected_tokens:, project:).perform
      end

      def perform
        split_string = Models::SplitString.new(
          base_string: selected_tokens_text,
          substring:   selected_text
        )

        [
          substring_token(value: split_string.substring_before),
          core_token,
          substring_token(value: split_string.substring_after)
        ].compact
      end

      private

      attr_reader :selected_text, :selected_tokens, :project

      delegate :witnesses_ids, to: :project, prefix: true

      # selected token that has multiple grouped variants
      def source_token
        @source_token ||= selected_tokens.detect { |token| !token.one_grouped_variant? }
      end

      def selected_tokens_text
        @selected_tokens_text ||= selected_tokens.map(&:t).join
      end

      def substring_token(value:)
        return if value.blank?

        record = Models::BasicTokenDetails.new(value:, witnesses_ids: project_witnesses_ids)
        build_token(record)
      end

      def core_token
        return substring_token(value: selected_text) if source_token.blank?

        record = Models::TokenWithSourceDetails.new(base_string: selected_text, source_token:)
        build_token(record)
      end

      def build_token(record)
        Token.new(
          project:,
          variants:         record.variants,
          grouped_variants: record.grouped_variants,
          editorial_remark: record.editorial_remark
        )
      end
    end
  end
end
