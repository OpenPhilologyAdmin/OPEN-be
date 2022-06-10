# frozen_string_literal: true

module Importer
  class Inserter
    TOKEN_IMPORT_COLUMNS = %i[index variants grouped_variants project_id].freeze
    attr_reader :project

    def initialize(name:, default_witness:, extracted_data:)
      @name            = name
      @default_witness = default_witness
      @extracted_data  = extracted_data
    end

    def process
      @project = create_project
      prepare_tokens
      save_tokens
    end

    private

    def create_project
      Project.create(
        name:            @name,
        default_witness: @default_witness,
        witnesses:       @extracted_data.witnesses
      )
    end

    def prepare_tokens
      @extracted_data.assign_project_id_to_tokens(@project.id)
    end

    def save_tokens
      Token.import(TOKEN_IMPORT_COLUMNS, @extracted_data.tokens)
    end
  end
end
