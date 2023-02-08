# frozen_string_literal: true

module Helpers
  module ApparatusExport
    def within_tag(value:, open_tag: nil, close_tag: nil)
      return value if open_tag.blank? && close_tag.blank?

      "#{open_tag} #{value}#{close_tag}"
    end

    def selected_grouped_variant_to_export(grouped_variant:, separator:, open_tag: nil, close_tag: nil)
      value = grouped_variant_value(grouped_variant:)
      witnesses = grouped_variant_witnesses(grouped_variant:)
      "#{within_tag(value: "#{value} #{separator}", open_tag:, close_tag:)} #{witnesses}"
    end

    def selected_grouped_variant_value(grouped_variant:, separator:)
      value = grouped_variant_value(grouped_variant:)
      "#{value} #{separator}"
    end

    def grouped_variants_to_export(grouped_variants:, separator:)
      grouped_variants.map do |grouped_variant|
        value = grouped_variant_value(grouped_variant:)
        witnesses = grouped_variant_witnesses(grouped_variant:)
        "#{witnesses}: #{value}"
      end.sort.join("#{separator} ")
    end

    def grouped_variant_value(grouped_variant:)
      grouped_variant.formatted_t.strip
    end

    def grouped_variant_witnesses(grouped_variant:)
      grouped_variant.witnesses.sort.join(TokenGroupedVariant::WITNESSES_SEPARATOR)
    end
  end
end
