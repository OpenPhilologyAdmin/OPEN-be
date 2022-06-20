# frozen_string_literal: true

module Importer
  module Extractors
    class TextPlain < Base
      STARTING_INDEX = 0

      def process
        prepare_tokens

        ::Importer::ExtractedData.new(tokens: @tokens, witnesses: [default_witness])
      end

      private

      def prepare_tokens
        token_content = @file.open(&:read)
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
          [
            {
              witness:  @default_witness,
              t:        content,
              selected: false,
              deleted:  false
            }
          ]
        ]
      end

      def grouped_variants_for(content)
        [
          {
            t:         content,
            witnesses: [@default_witness],
            selected:  false
          }
        ]
      end

      def default_witness
        Witness.new(
          siglum: @default_witness,
          name:   nil
        )
      end
    end
  end
end
