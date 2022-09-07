# frozen_string_literal: true

module Helpers
  module TokenVariants
    def find_variant(variants:, witness:)
      variants.find { |v| v.for_witness?(witness) }
    end
  end
end
