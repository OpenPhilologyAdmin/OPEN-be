# frozen_string_literal: true

module Apparatus
  class SignificantEntry < Entry
    delegate :selected_variant, :secondary_variants, to: :token

    def value
      return nil unless apparatus?

      {
        selected_reading:,
        details:
      }
    end

    private

    def details
      secondary_readings.unshift(selected_reading_witnesses).join(', ')
    end

    def secondary_readings
      secondary_variants.map do |variant|
        full_reading_for(variant:)
      end
    end
  end
end
