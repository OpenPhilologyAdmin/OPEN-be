# frozen_string_literal: true

module Importer
  module Extractors
    class Base
      attr_accessor :project, :default_witness, :source_file

      delegate :default_witness, :source_file, to: :project

      def initialize(project:)
        @project = project
        @tokens = []
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
