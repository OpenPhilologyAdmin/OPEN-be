# frozen_string_literal: true

module WitnessesManager
  class Remover
    class TokenProcessor
      def initialize(token:, siglum:)
        @token = token
        @siglum = siglum
      end

      def remove_witness
        remove_variant
        process_grouped_variant
      end

      private

      def remove_variant
        @token.variants.delete_if { |variant| variant.for_witness?(@siglum) }
      end

      def grouped_variant
        @grouped_variant ||= @token.grouped_variants.find { |grouped_variant| grouped_variant.for_witness?(@siglum) }
      end

      def grouped_variant_multiple_witnesses?
        grouped_variant.witnesses.size > 1
      end

      def process_grouped_variant
        return unless grouped_variant

        if grouped_variant_multiple_witnesses?
          grouped_variant.witnesses.delete(@siglum)
          @grouped_variant = nil
        else
          @token.grouped_variants.delete(grouped_variant)
        end
      end
    end
  end
end
