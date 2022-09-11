# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class TokenWithSourceDetails
        attr_reader :variants, :editorial_remark, :grouped_variants

        def initialize(base_string:, source_token:)
          @split_string     = SplitString.new(base_string:, substring: source_token.t)
          @variants         = source_token.variants.deep_dup
          @grouped_variants = source_token.grouped_variants.deep_dup
          @editorial_remark = source_token.editorial_remark.deep_dup
          process_values
        end

        private

        attr_reader :split_string

        delegate :substring_before, :substring_after, to: :split_string, allow_nil: true

        def process_values
          [variants, editorial_remark, grouped_variants].flatten.compact.each do |resource|
            resource.t = ProcessedString.new(string: resource.t, substring_before:, substring_after:).string
          end
        end
      end
    end
  end
end
