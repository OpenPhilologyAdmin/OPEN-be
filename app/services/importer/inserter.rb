# frozen_string_literal: true

module Importer
  class Inserter
    attr_reader :project

    def initialize(name:, default_witness:, extracted_data:)
      @name            = name
      @default_witness = default_witness
      @extracted_data  = extracted_data
    end

    def process
      @project = create_project
    end

    private

    def create_project
      Project.create(
        name:            @name,
        default_witness: @default_witness,
        witnesses:       @extracted_data.witnesses
      )
    end
  end
end
