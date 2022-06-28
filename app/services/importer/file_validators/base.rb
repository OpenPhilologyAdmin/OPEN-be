# frozen_string_literal: true

module Importer
  module FileValidators
    class Base
      attr_accessor :project, :source_file, :errors, :file_content

      delegate :source_file, to: :project

      def initialize(project:)
        @project = project
        @errors = []
      end

      def validate
        raise NotImplementedError
      end
    end
  end
end
