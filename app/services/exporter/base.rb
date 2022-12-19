# frozen_string_literal: true

module Exporter
  class Base
    def initialize(project:, options: {})
      @project           = project
      @exporter_options  = ExporterOptions.new(
        footnote_numbering: options[:footnote_numbering],
        layout:             options[:layout]
      )
      @apparatus_options = ApparatusOptions.new(
        significant_readings:             options[:significant_readings],
        insignificant_readings:           options[:insignificant_readings],
        selected_reading_separator:       options[:selected_reading_separator],
        secondary_readings_separator:     options[:secondary_readings_separator],
        insignificant_readings_separator: options[:insignificant_readings_separator],
        entries_separator:                options[:entries_separator]
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

    attr_reader :project, :exporter_options, :apparatus_options

    def options_valid?
      exporter_options.valid? && apparatus_options.valid?
    end

    def data
      @data ||= document.to_export
    end

    def errors
      @errors ||= Models::ExportErrors.new(
        exporter_options:,
        apparatus_options:
      ).errors
    end

    def document
      @document ||= Models::Document.new(paragraphs:)
    end

    def paragraphs
      @paragraphs ||= ParagraphsPreparer.perform(
        project:,
        exporter_options:,
        apparatus_options:
      )
    end
  end
end
