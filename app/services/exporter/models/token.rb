# frozen_string_literal: true

module Exporter
  module Models
    class Token < DocumentItem
      def initialize(value:, footnote_numbering: false, index: nil)
        @value = value
        @footnote_numbering = footnote_numbering
        @index = index
        super
      end

      def to_export
        return value unless include_footnote?

        "#{value}#{to_style(style: :superscript, given_value: index)}"
      end

      private

      attr_reader :value, :index, :footnote_numbering
      alias footnote_numbering? footnote_numbering

      def include_footnote?
        index && footnote_numbering?
      end
    end
  end
end
