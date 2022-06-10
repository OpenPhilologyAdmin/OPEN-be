# frozen_string_literal: true

module Importer
  module Extractors
    module Models
      class ExtractedData
        attr_accessor :tokens, :witnesses

        def initialize(data)
          @tokens    = data[:tokens]
          @witnesses = data[:witnesses]
        end

        def assign_project_id_to_tokens(project_id)
          @tokens.each { |token| token << project_id }
        end
      end
    end
  end
end
