# frozen_string_literal: true

module WitnessesManager
  class Base
    def initialize(project:, siglum:, user:, params: {})
      @project = project
      @siglum  = siglum
      @params = params
      @user = user
      @witness = @project.find_witness!(siglum)
    end

    def self.perform(project:, siglum:, user:, params: {})
      new(project:, siglum:, user:, params:).perform
    end

    def perform
      raise NotImplementedError
    end
  end
end
