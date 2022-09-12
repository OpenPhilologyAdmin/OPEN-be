# frozen_string_literal: true

module TokensManager
  class Resizer
    module Processors
      class RedundantTokensRemover
        def initialize(project:, tokens_to_remove:, relevant_tokens:)
          @project          = project
          @tokens_to_remove = tokens_to_remove
          @relevant_tokens  = relevant_tokens
        end

        def self.perform(project:, tokens_to_remove:, relevant_tokens:)
          new(project:, tokens_to_remove:, relevant_tokens:).perform
        end

        def perform
          redundant_tokens = tokens_to_remove - relevant_tokens
          project_tokens.where(id: redundant_tokens.pluck(:id)).destroy_all
        end

        private

        attr_reader :project, :tokens_to_remove, :relevant_tokens

        delegate :tokens, to: :project, prefix: true
      end
    end
  end
end
