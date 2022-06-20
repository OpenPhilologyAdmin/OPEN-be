# frozen_string_literal: true

module Importer
  class Base
    include Importer::Concerns::Validators
    attr_reader :errors

    def initialize(project:)
      @project         = project
      @errors          = {}
    end

    def process
      perform_validations
      return unless valid?

      extract_data
    end

    private

    def mime_type
      @mime_type ||= @project.source_file_content_type
    end

    def extractor_klass
      "Importer::Extractors::#{mime_type.titleize.gsub(%r{/}, '')}".constantize
    end

    def extractor
      @extractor ||= extractor_klass.new(project: @project)
    end

    def extract_data
      extractor.process
    rescue SyntaxError, NameError
      add_error(:file, I18n.t('importer.errors.unsupported_file_format'))
    end
  end
end
