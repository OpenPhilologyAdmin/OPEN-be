# frozen_string_literal: true

module Importer
  class Base
    include Importer::Concerns::Validators
    attr_accessor :errors, :extracted_data

    def initialize(project:, user:)
      @project = project
      @user = user
      @errors = {}
    end

    def process
      save_owner
      perform_validations
      return unless valid?

      process_data
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

    def inserter
      @inserter ||= Inserter.new(project: @project, extracted_data: @extracted_data)
    end

    def save_owner
      ProjectRole.create(user: @user, project: @project)
    end

    def extract_data
      extractor.process
    rescue SyntaxError, NameError
      add_error(:file, I18n.t('importer.errors.unsupported_file_format'))
    end

    def insert_data
      inserter.process
    end

    def process_data
      @extracted_data = extract_data
      return unless valid?

      insert_data
    end
  end
end
