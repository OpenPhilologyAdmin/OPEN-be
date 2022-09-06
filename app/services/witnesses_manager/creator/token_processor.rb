# frozen_string_literal: true

module WitnessesManager
  class Creator
    class TokenProcessor
      def initialize(token:, siglum:)
        @token = token
        @siglum = siglum
      end

      def add_witness
        add_variant
        generate_grouped_variants
      end

      private

      attr_reader :token, :siglum

      def add_variant
        token.variants << TokenVariant.new(witness: siglum, t: token.current_variant.t)
      end

      def generate_grouped_variants
        token.grouped_variants = TokensManager::GroupedVariantsGenerator.perform(token:)
      end
    end
  end
end
