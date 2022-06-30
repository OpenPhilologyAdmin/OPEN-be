# frozen_string_literal: true

module Importer
  class Base
    include Importer::Concerns::Validators
    attr_accessor :extracted_data, :project

    delegate :import_errors, to: :project

    def initialize(project:, user:, default_witness_name: nil)
      @project = project
      @user = user
      @default_witness_name = default_witness_name
    end

    def process
      save_owner
      perform_validations
      return unless valid?

      process_data
    end

    private

    def mime_type
      @mime_type ||= project.source_file_content_type
    end

    def processed_mime_type
      mime_type.titleize.gsub(%r{/}, '')
    end

    def extractor_klass
      "Importer::Extractors::#{processed_mime_type}".constantize
    end

    def extractor
      @extractor ||= extractor_klass.new(project:, default_witness_name: @default_witness_name)
    end

    def inserter
      @inserter ||= Inserter.new(project:, extracted_data: @extracted_data)
    end

    def save_owner
      ProjectRole.create(user: @user, project:)
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
