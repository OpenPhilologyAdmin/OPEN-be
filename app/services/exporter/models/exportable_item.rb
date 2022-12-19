# frozen_string_literal: true

module Exporter
  module Models
    class ExportableItem
      def initialize(**attributes); end

      def to_export
        raise NotImplementedError
      end

      private

      def styler
        @styler ||= Exporter::Models::Stylers::Rtf.new
      end

      def to_style(given_value:, style:)
        styler.perform(value: given_value, style:)
      end
    end
  end
end
