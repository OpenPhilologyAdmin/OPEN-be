# frozen_string_literal: true

module Importer
  module Extractors
    class TextPlain < Base
      STARTING_INDEX = 0

      def process
        token_content = @file.read
        @tokens << prepare_token(token_content, STARTING_INDEX)
        @file.close
        @tokens
      end

      private

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
    end
  end
end
