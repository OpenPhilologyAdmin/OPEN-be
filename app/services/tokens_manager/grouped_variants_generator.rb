# frozen_string_literal: true

module TokensManager
  class GroupedVariantsGenerator
    def initialize(token:)
      @token = token
      @variants_hash = process_variants
    end

    def self.perform(token:)
      new(token:).perform
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

    attr_reader :token, :variants_hash

    def variants_and_remarks
      @variants_and_remarks ||= [token.variants, token.editorial_remark].flatten.compact
    end

    def process_variants
      processed_variants = Hash.new { |hash, key| hash[key] = [] }
      variants_and_remarks.each do |variant|
        processed_variants[variant.t] << variant.witness
      end
      processed_variants
    end
  end
end
