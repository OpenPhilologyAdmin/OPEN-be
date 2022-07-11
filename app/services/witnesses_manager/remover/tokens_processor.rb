# frozen_string_literal: true

module WitnessesManager
  class Remover
    class TokensProcessor
      COLUMNS_TO_UPDATE = %i[variants grouped_variants].freeze

      def initialize(tokens:, siglum:)
        @tokens = tokens
        @siglum = siglum
      end

      def remove_witness!
        return if @tokens.empty?

        process_tokens
        save_tokens
      end

      private

      def process_tokens
        @tokens.each do |token|
          TokenProcessor.new(token:, siglum: @siglum).remove_witness
        end
      end

      def save_tokens
        Token.import(
          @tokens,
          on_duplicate_key_update: {
            conflict_target: [:id],
            columns:         COLUMNS_TO_UPDATE
          }
        )
      end
    end
  end
end
