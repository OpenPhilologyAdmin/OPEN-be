# frozen_string_literal: true

module Apparatus
  class InsignificantEntry < Entry
    delegate :insignificant_variants, to: :token

    def value
      return nil unless apparatus?

      {
        selected_reading:,
        details:
      }
    end

    private

    def details
      insignificant_readings.join(', ')
    end

    def insignificant_readings
      insignificant_variants.map do |variant|
        full_reading_for(variant:)
      end
    end
  end
end
