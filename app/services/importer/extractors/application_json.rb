# frozen_string_literal: true

module Importer
  module Extractors
    class ApplicationJson < Base
      EMPTY_VARIANT_VALUE = nil
      WITNESSES_KEY = 'witnesses'
      TOKENS_KEY = 'table'

      def initialize(project:)
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
            [{
              witness:  variant[:witness],
              t:        variant[:t],
              selected: false,
              deleted:  false
            }]
          end
        end

        def grouped_variants
          @grouped_variants ||= variants_hash.map do |(variant, witnesses)|
            {
              t:         variant,
              witnesses:,
              selected:  false
            }
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

        def variant_value_for(variant)
          return EMPTY_VARIANT_VALUE if variant.empty?

          value = variant.first

          # The value can be either a simple string or a Hash
          value.is_a?(Hash) ? value.fetch('t', EMPTY_VARIANT_VALUE) : value
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
