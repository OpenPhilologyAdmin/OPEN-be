# frozen_string_literal: true

module Importer
  class Inserter
    attr_reader :project

    def initialize(project:, extracted_data:)
      @project        = project
      @extracted_data = extracted_data
    end

    def process
      save_tokens
      update_project
    end

    private

    def update_project
      @project.update(
        witnesses: @extracted_data.witnesses,
        status:    :processed
      )
    end

    def save_tokens
      Token.import(@extracted_data.tokens)
    end
  end
end
