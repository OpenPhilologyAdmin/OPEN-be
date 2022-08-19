# frozen_string_literal: true

module TokensManager
  class GroupedVariantsGenerator
    attr_reader :variants_hash

    def initialize(variants)
      @variants_hash = process_variants(variants)
    end

    def self.perform(variants)
      new(variants).perform
    end

    def perform
      variants_hash.map do |(variant, witnesses)|
        TokenGroupedVariant.new(
          t:         variant,
          witnesses:,
          selected:  false,
          possible:  false
        )
      end
    end

    private

    def process_variants(variants)
      processed_variants = Hash.new { |hash, key| hash[key] = [] }
      variants.each do |variant|
        processed_variants[variant.t] << variant.witness
      end
      processed_variants
    end
  end
end
