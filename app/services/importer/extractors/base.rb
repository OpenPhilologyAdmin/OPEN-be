# frozen_string_literal: true

module Importer
  module Extractors
    class Base
      def initialize(project:)
        @project = project
        @file = @project.source_file
        @default_witness = @project.default_witness
        @tokens = []
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
