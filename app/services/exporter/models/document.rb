# frozen_string_literal: true

module Exporter
  module Models
    class Document
      attr_reader :paragraphs

      def initialize(paragraphs: [])
        @paragraphs = paragraphs
      end

      def to_export
        paragraphs_to_export
      end

      private

      def paragraphs_to_export
        @paragraphs_to_export ||= paragraphs.map(&:to_export).join
      end
    end
  end
end
