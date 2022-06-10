# frozen_string_literal: true

module Importer
  class ExtractedData
    include ActiveModel::Model

    attr_accessor :tokens, :witnesses

    def assign_project_id_to_tokens(project_id)
      tokens.each { |token| token << project_id }
    end
  end
end
