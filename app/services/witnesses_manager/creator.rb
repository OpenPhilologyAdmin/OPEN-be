# frozen_string_literal: true

module WitnessesManager
  class Creator
    def initialize(project:, user:, params: {})
      @project = project
      @user    = user
      @params  = params
    end

    def perform
      add_witness_to_project
      add_witness_to_tokens
      Result.new(
        success: project.save,
        witness:
      )
    end

    def self.perform(project:, user:, params: {})
      new(project:, user:, params:).perform
    end

    private

    attr_reader :user, :params
    attr_accessor :project, :witness

    def add_witness_to_project
      project.witnesses << Witness.new(params)
      @witness = project.witnesses.last
    end

    def add_witness_to_tokens
      return unless witness.valid?

      processor = TokensProcessor.new(
        tokens: project.tokens,
        siglum: witness.siglum
      )
      processor.add_witness
    end
  end
end
