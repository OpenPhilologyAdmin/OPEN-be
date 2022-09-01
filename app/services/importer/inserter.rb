# frozen_string_literal: true

module Importer
  class Inserter
    attr_reader :project

    def initialize(project:, extracted_data:)
      @project        = project
      @extracted_data = extracted_data
    end

    def process
      prepare_project
      save_tokens
      project.save
    end

    private

    attr_reader :extracted_data

    def prepare_project
      project.assign_attributes(
        witnesses: extracted_data.witnesses,
        status:    :processed
      )
      project.witnesses.first.default!
    end

    def save_tokens
      Token.import(extracted_data.tokens)
    end
  end
end
