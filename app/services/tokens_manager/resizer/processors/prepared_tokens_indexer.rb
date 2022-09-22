# frozen_string_literal: true

module TokensManager
  class Resizer
    module Processors
      class PreparedTokensIndexer
        def initialize(starting_index:, prepared_tokens:)
          @prepared_tokens = prepared_tokens
          @starting_index      = starting_index
        end

        def self.perform(starting_index:, prepared_tokens:)
          new(starting_index:, prepared_tokens:).perform
        end

        def perform
          index = starting_index
          prepared_tokens.each do |token|
            token.index = index
            index += 1
          end
        end

        private

        attr_reader :prepared_tokens, :starting_index
      end
    end
  end
end
