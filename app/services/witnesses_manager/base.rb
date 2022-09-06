# frozen_string_literal: true

module WitnessesManager
  class Base
    def initialize(project:, siglum:, user:, params: {})
      @project = project
      @siglum  = siglum
      @params = params
      @witness = @project.find_witness!(siglum)
      assign_last_editor(user)
    end

    def self.perform(project:, siglum:, user:, params: {})
      new(project:, siglum:, user:, params:).perform
    end

    def perform
      raise NotImplementedError
    end

    private

    def assign_last_editor(user)
      @project.last_editor = user
    end
  end
end
