# frozen_string_literal: true

module TokensManager
  class Resizer
    module Models
      class TokenWithSourceDetails
        include Concerns::Placeholderable

        attr_reader :grouped_variants

        def initialize(base_string:, source_token:)
          @base_string      = base_string
          @source_token     = source_token
          @grouped_variants = GroupedVariantsGenerator.perform(token: self)
          copy_selections
        end

        def variants
          @variants ||= source_token_variants.map do |variant|
            TokenVariant.new(
              t:       with_substrings(value: variant.t),
              witness: variant.witness
            )
          end
        end

        def editorial_remark
          return if source_token_editorial_remark.blank?

          @editorial_remark ||= TokenEditorialRemark.new(
            t:    with_substrings(value: source_token_editorial_remark.t),
            type: source_token_editorial_remark.type
          )
        end

        private

        attr_reader :base_string, :source_token

        delegate :variants, to: :source_token, prefix: true
        delegate :editorial_remark, to: :source_token, prefix: true, allow_nil: true
        delegate :substring_before, :substring_after, to: :split_string, allow_nil: true

        def split_string
          @split_string ||= SplitString.new(base_string:, substring: source_token.t)
        end

        def with_substrings(value:)
          without_placeholders(value: "#{substring_before}#{value}#{substring_after}")
        end

        def copy_selections
          SelectionsCopier.perform(
            target_grouped_variants: grouped_variants,
            source_grouped_variants: source_token.grouped_variants
          )
        end
      end
    end
  end
end
