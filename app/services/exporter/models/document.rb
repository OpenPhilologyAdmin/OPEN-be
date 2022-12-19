# frozen_string_literal: true

module Exporter
  module Models
    class Document < ExportableItem
      include Helpers::AsciiEscaper

      attr_reader :paragraphs

      def initialize(paragraphs: [])
        @paragraphs = paragraphs
        super
      end

      def to_export
        to_style(style: :document, given_value: escaped_to_export_value)
      end

      private

      def paragraphs_to_export
        @paragraphs_to_export ||= paragraphs.map(&:to_export).join
      end

      def escaped_to_export_value
        to_escaped_string(value: paragraphs_to_export)
      end
    end
  end
end
