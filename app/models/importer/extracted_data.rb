# frozen_string_literal: true

module Importer
  class ExtractedData
    include ActiveModel::Model

    attr_accessor :tokens, :witnesses

    def assign_project_to_tokens(project)
      tokens.each { |token| token.project = project }
    end
  end
end
