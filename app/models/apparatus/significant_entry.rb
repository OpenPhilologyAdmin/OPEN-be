# frozen_string_literal: true

module Apparatus
  class SignificantEntry < Entry
    delegate :selected_variant, :secondary_variants, to: :token

    def value
      return nil unless apparatus?

      secondary_readings.unshift(selected_reading).join(', ')
    end

    private

    def selected_reading
      reading_for(variant: selected_variant, separator: ']')
    end

    def secondary_readings
      secondary_variants.map do |variant|
        reading_for(variant:)
      end
    end
  end
end