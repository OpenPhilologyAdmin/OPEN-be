# frozen_string_literal: true

module WitnessesManager
  class Base
    include EditTrackerHelper

    def initialize(project:, siglum:, user:, params: {})
      @project = project
      @siglum  = siglum
      @params = params
      @user = user
      @witness = @project.find_witness!(siglum)

      update_last_editor(user:, project:)
      update_last_edited_project(project:, user:)
    end

    def self.perform(project:, siglum:, user:, params: {})
      new(project:, siglum:, user:, params:).perform
    end

    def perform
      raise NotImplementedError
    end
  end
end
