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
      end
    end
  end
end
