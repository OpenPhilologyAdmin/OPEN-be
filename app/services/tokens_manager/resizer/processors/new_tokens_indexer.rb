# frozen_string_literal: true

module TokensManager
  class Resizer
    module Processors
      class NewTokensIndexer
        def initialize(starting_index:, new_tokens:)
          @new_tokens = new_tokens
          @starting_index      = starting_index
        end

        def self.perform(starting_index:, new_tokens:)
          new(starting_index:, new_tokens:).perform
        end

        def perform
          index = starting_index
          new_tokens.each do |token|
            token.index = index
            index += 1
          end
        end

        private

        attr_reader :new_tokens, :starting_index
      end
    end
  end
end
