# frozen_string_literal: true

module Exporter
  module Models
    module Stylers
      class Rtf < Exporter::Models::Styler
        COLOR_VIOLET = '\\red93\\green45\\blue239'
        COLOR_ORANGE = '\\red252\\green97\\blue69'

        def to_superscript(value:, options: {})
          "{\\super #{value}}"
        end

        def to_bold(value:, options: {})
          "{\\b #{value}}"
        end

        def to_paragraph(value:, options: {})
          "{\\pard\\sl360\\slmult1\n#{value}\n\\par}\n"
        end

        def to_indented_line(value:, options: {})
          "{\\li720 #{value} #{options[:include_line_break] ? '\\line' : ''}}\n"
        end

        def to_color(value:, options: {})
          "\\#{options[:color]} #{value}"
        end

        def to_document(value:, options: {})
          '{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}' \
            "{\\colortbl;#{COLOR_VIOLET};#{COLOR_ORANGE};}\n" \
            "#{value}\n}"
        end
      end
    end
  end
end
