# frozen_string_literal: true

module Importer
  module Extractors
    class ApplicationJson < Base
      EMPTY_VARIANT_VALUE = nil
      WITNESSES_KEY = 'witnesses'
      TOKENS_KEY = 'table'

      def initialize(project:, default_witness_name: nil)
        super
        prepare_tokens
      end

      def process
        ::Importer::ExtractedData.new(tokens: @tokens, witnesses:)
      end

      private

      def file_content
        @file_content ||= JSON.parse(source_file.open(&:read))
      end

      def witnesses
        @witnesses ||= file_content[WITNESSES_KEY].map do |siglum|
          Witness.new(siglum:, name: nil)
        end
      end

      def prepare_tokens
        file_content[TOKENS_KEY].each_with_index do |token_content, token_index|
          @tokens << token_at(token_index, token_content)
        end
      end

      def token_at(index, content)
        extracted_token = ExtractedToken.new(content, witnesses)

        Token.new(
          index:,
          project:          @project,
          variants:         extracted_token.variants,
          grouped_variants: extracted_token.grouped_variants
        )
      end

      class ExtractedToken
        def initialize(content, witnesses)
          @witnesses = witnesses
          @simplified_variants = simplified_variants_for(content)
        end

        def variants
          @variants ||= @simplified_variants.map do |variant|
            TokenVariant.new(
              witness:  variant[:witness],
              t:        variant[:t],
              selected: false,
              possible: false,
              deleted:  false
            )
          end
        end

        def grouped_variants
          @grouped_variants ||= variants_hash.map do |(variant, witnesses)|
            TokenGroupedVariant.new(
              t:         variant,
              witnesses:,
              selected:  false,
              possible:  false
            )
          end
        end

        private

        def simplified_variants_for(content)
          content.map.with_index do |variant, variant_index|
            {
              witness: witness_for(variant_index),
              t:       variant_value_for(variant)
            }
          end
        end

        def witness_for(index)
          @witnesses[index].siglum
        end

        def variant_value_for(variant_values)
          return EMPTY_VARIANT_VALUE if variant_values.empty?

          # The variant_values can be either an array of Strings or Hashes
          if variant_values.first.is_a?(Hash)
            variant_values = variant_values.map { |v| v.fetch('t', EMPTY_VARIANT_VALUE) }
          end
          variant_values.join
        end

        def variants_hash
          @variants_hash ||= Hash.new { |h, k| h[k] = [] }
          @simplified_variants.each do |variant|
            @variants_hash[variant[:t]] << variant[:witness]
          end

          @variants_hash
        end
      end
    end
  end
end
