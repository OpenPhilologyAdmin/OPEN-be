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
          "{\\par #{value} \\par}"
        end
      end
    end
  end
end
