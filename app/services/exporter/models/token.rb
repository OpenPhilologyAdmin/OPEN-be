# frozen_string_literal: true

module Exporter
  module Models
    class Token < ExportableItem
      def initialize(value:, footnote_numbering: false, apparatus_entry_index: nil)
        @value = value
        @footnote_numbering = footnote_numbering
        @apparatus_entry_index = apparatus_entry_index
        super
      end

      def to_export
        return value unless include_footnote?

        "#{value.rstrip}#{to_style(style: :superscript, given_value: "(#{apparatus_entry_index})")} "
      end

      private

      attr_reader :value, :apparatus_entry_index, :footnote_numbering
      alias footnote_numbering? footnote_numbering

      def include_footnote?
        apparatus_entry_index && footnote_numbering?
      end
    end
  end
end
