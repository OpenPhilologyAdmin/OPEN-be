# frozen_string_literal: true

module Exporter
  module Models
    class Paragraph < ExportableItem
      attr_reader :contents

      def initialize(contents: [])
        @contents = contents
        super
      end

      def to_export
        to_style(style: :paragraph, given_value: contents_to_export)
      end

      private

      def contents_to_export
        @contents_to_export ||= contents.map(&:to_export).join
      end
    end
  end
end
