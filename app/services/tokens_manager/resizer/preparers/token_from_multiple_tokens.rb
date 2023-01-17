# frozen_string_literal: true

module TokensManager
  class Resizer
    module Preparers
      class TokenFromMultipleTokens
        def initialize(params:)
          @params = params
          @token = build_token
        end

        def self.perform(params:)
          new(params:).perform
        end

        def perform
          generate_variants
          generate_grouped_variants
          token
        end

        private

        attr_reader :token, :params

        delegate :selected_tokens, :project, to: :params
        delegate :witnesses_ids, to: :project

        def build_token
          project.tokens.new(
            resized:  true,
            variants: [],
            index:
          )
        end

        def index
          selected_tokens.first.index
        end

        def generate_variants
          witnesses_ids.each do |witness|
            token.variants << prepare_variant_for(witness:)
          end
        end

        def prepare_variant_for(witness:)
          variant = TokenVariant.new(witness:)
          selected_tokens.each do |selected_token|
            selected_token_variant_value = variant_value_for(selected_token:, witness:)
            next if selected_token_variant_value.nil?

            # variant.t is nil by default
            variant.t = "#{variant.t}#{selected_token_variant_value}"
          end
          variant
        end

        def variant_value_for(selected_token:, witness:)
          variant_for(selected_token:, witness:).t
        end

        def variant_for(selected_token:, witness:)
          selected_token.variants.find { |variant| variant.for_witness?(witness) }
        end

        def generate_grouped_variants
          token.grouped_variants = GroupedVariantsGenerator.perform(token:)
        end
      end
    end
  end
end
