# frozen_string_literal: true

module Importer
  class Base
    include Importer::Concerns::Validators
    attr_reader :errors

    def initialize(data_path:, name:, default_witness:)
      @data_path       = Rails.root.join(data_path)
      @errors          = {}
      @name            = name
      @default_witness = default_witness
    end

    def process
      perform_validations
      return unless valid?

      extract_data
    end

    private

    def mime_type
      @mime_type ||= Marcel::MimeType.for(@data_path, name: @data_path.basename)
    end

    def extractor_klass
      "Importer::Extractors::#{mime_type.titleize.gsub(%r{/}, '')}".constantize
    end

    def extractor
      @extractor ||= extractor_klass.new(data_path: @data_path, default_witness: @default_witness)
    end

    def extract_data
      extractor.process
    rescue SyntaxError, NameError
      add_error(:file, I18n.t('importer.errors.unsupported_file_format'))
    end
  end
end
