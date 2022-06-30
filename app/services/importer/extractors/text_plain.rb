# frozen_string_literal: true

module Importer
  module Extractors
    class TextPlain < Base
      STARTING_INDEX = 0

      def process
        prepare_tokens

        ::Importer::ExtractedData.new(tokens: @tokens, witnesses: extracted_witnesses)
      end

      private

      def prepare_tokens
        token_content = source_file.open(&:read)
        @tokens << token_at(STARTING_INDEX, token_content)
      end

      def token_at(index, content)
        Token.new(
          index:,
          project:          @project,
          variants:         variants_for(content),
          grouped_variants: grouped_variants_for(content)
        )
      end

      def variants_for(content)
        [
          TokenVariant.new(
            witness:  default_witness,
            t:        content,
            selected: false,
            possible: false,
            deleted:  false
          )
        ]
      end

      def grouped_variants_for(content)
        [
          TokenGroupedVariant.new(
            t:         content,
            witnesses: [default_witness],
            selected:  false,
            possible:  false
          )
        ]
      end

      def extracted_witnesses
        [
          Witness.new(
            siglum: default_witness,
            name:   @default_witness_name
          )
        ]
      end
    end
  end
end
