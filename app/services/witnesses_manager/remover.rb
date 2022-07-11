# frozen_string_literal: true

module WitnessesManager
  class Remover < Base
    def perform!
      remove_witness_from_project
      remove_witness_from_tokens
    end

    private

    def remove_witness_from_project
      processor = ProjectWitnessesProcessor.new(project: @project, siglum: @siglum)
      processor.remove_witness!
    end

    def remove_witness_from_tokens
      processor = TokensProcessor.new(tokens: @project.tokens, siglum: @siglum)
      processor.remove_witness!
    end
  end
end
