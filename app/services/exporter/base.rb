# frozen_string_literal: true

module Exporter
  class Base
    def initialize(project:, options: {})
      @project           = project
      @apparatus_options = ApparatusOptions.new(
        footnote_numbering:         options[:footnote_numbering],
        significant_readings:       options[:significant_readings],
        insignificant_readings:     options[:insignificant_readings],
        selected_reading_separator: options[:selected_reading_separator],
        readings_separator:         options[:readings_separator],
        sigla_separator:            options[:sigla_separator]
      )
    end

    def self.perform(project:, options:)
      new(project:, options:).perform
    end

    def perform
      if options_valid?
        Models::Result.new(
          success: true,
          data:
        )
      else
        Models::Result.new(
          success: false,
          errors:
        )
      end
    end

    private

    attr_reader :project, :apparatus_options

    def options_valid?
      apparatus_options.valid?
    end

    def data
      @data ||= document.to_export
    end

    def errors
      @errors ||= Models::ExportErrors.new(
        apparatus_options:
      ).errors
    end

    def document
      @document ||= Models::Document.new(paragraphs:)
    end

    def paragraphs
      @paragraphs ||= ParagraphsPreparer.perform(
        project:,
        apparatus_options:
      )
    end
  end
end
