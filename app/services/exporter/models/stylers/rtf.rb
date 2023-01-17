# frozen_string_literal: true

module Exporter
  module Models
    module Stylers
      class Rtf < Exporter::Models::Styler
        def to_superscript(value:)
          "{\\super #{value}}"
        end

        def to_bold(value:)
          "{\\b #{value}}"
        end

        def to_paragraph(value:)
          "{\\par\n#{value}\n\\par}\n"
        end

        def to_document(value:)
          "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\n#{value}\n}"
        end
      end
    end
  end
end
