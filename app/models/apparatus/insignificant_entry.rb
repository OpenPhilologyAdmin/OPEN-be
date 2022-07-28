# frozen_string_literal: true

module Apparatus
  class InsignificantEntry < Entry
    delegate :insignificant_variants, to: :token

    def value
      return nil unless apparatus?

      insignificant_readings.join(', ')
    end

    private

    def insignificant_readings
      insignificant_variants.map do |variant|
        reading_for(variant:)
      end
    end
  end
end
