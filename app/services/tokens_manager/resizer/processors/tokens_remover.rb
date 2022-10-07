# frozen_string_literal: true

module TokensManager
  class Resizer
    module Processors
      class TokensRemover
        def initialize(project:, tokens_to_remove:)
          @project = project
          @tokens_to_remove_ids = tokens_to_remove.pluck(:id)
        end

        def self.perform(project:, tokens_to_remove:)
          new(project:, tokens_to_remove:).perform
        end

        def perform
          project_tokens.where(id: tokens_to_remove_ids).update(deleted: true)
        end

        private

        attr_reader :project, :tokens_to_remove_ids

        delegate :tokens, to: :project, prefix: true
      end
    end
  end
end
