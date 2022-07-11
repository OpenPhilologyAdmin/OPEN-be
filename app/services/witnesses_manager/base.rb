# frozen_string_literal: true

module WitnessesManager
  class Base
    def initialize(project:, siglum:, params: {})
      @project = project
      @siglum  = siglum
      @params = params
      @witness = @project.find_witness!(siglum)
    end

    def self.perform!(project:, siglum:, params: {})
      new(project:, siglum:, params:).perform!
    end

    def perform!
      raise NotImplementedError
    end
  end
end
