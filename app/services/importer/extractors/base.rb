# frozen_string_literal: true

module Importer
  module Extractors
    class Base
      attr_accessor :project, :default_witness, :source_file

      delegate :default_witness, :source_file, to: :project

      def initialize(project:, default_witness_name: nil)
        @project = project
        @tokens = []
        @default_witness_name = default_witness_name
      end

      def process
        raise NotImplementedError
      end
    end
  end
end
