# frozen_string_literal: true

module Importer
  module Extractors
    class TextPlain < Base
      STARTING_INDEX = 0

      def process
        prepare_tokens

        Models::ExtractedData.new(tokens: @tokens, witnesses: [prepare_witness])
      end

      private

      def prepare_tokens
        token_content = @file.read
        @tokens << prepare_token(token_content, STARTING_INDEX)
        @file.close
      end

      def prepare_token(content, index)
        [index, variants_for(content), grouped_variants_for(content)]
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

      def prepare_witness
        {
          siglum: @default_witness,
          name:   nil
        }
      end
    end
  end
end
