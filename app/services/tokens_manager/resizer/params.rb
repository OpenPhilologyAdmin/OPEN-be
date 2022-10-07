# frozen_string_literal: true

module TokensManager
  class Resizer
    class Params
      attr_reader :project, :selected_text, :selected_tokens, :tokens_with_offsets

      def initialize(project:, selected_text:, selected_token_ids:, tokens_with_offsets:)
        @project             = project
        @selected_text       = selected_text
        @selected_tokens     = project.tokens.where(id: selected_token_ids)
        @tokens_with_offsets = tokens_with_offsets
      end

      def selected_multiple_readings_token
        @selected_multiple_readings_token ||= selected_tokens.detect { |token| !token.one_grouped_variant? }
      end
    end
  end
end
