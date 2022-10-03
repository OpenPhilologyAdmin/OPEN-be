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
        update_grouped_variants

        token.save
      end

      private

      attr_reader :token, :siglum

      def add_variant
        token.variants << TokenVariant.new(witness: siglum, t: token.current_variant.t)
      end

      def update_grouped_variants
        grouped_variant = token.grouped_variants.find { |record| record.t == token.current_variant.t }
        grouped_variant.witnesses << siglum if grouped_variant.present?
      end
    end
  end
end
