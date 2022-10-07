# frozen_string_literal: true

module Helpers
  module TokenVariants
    def find_variant(variants:, witness:)
      variants.find { |v| v.for_witness?(witness) }
    end

    def find_grouped_variant(grouped_variants:, witnesses:)
      grouped_variants.find { |v| v.witnesses.sort == witnesses.sort }
    end

    def generate_grouped_variants(token:)
      TokensManager::GroupedVariantsGenerator.perform(token:)
    end
  end
end
