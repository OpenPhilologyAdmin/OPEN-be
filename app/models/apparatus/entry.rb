# frozen_string_literal: true

module Apparatus
  class Entry
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include Concerns::FormattableReading

    ENTRIES_SEPARATOR = '; '
    SELECTED_READING_SEPARATOR = ']'

    attr_accessor :token, :index

    delegate :id, to: :token, prefix: true
    delegate :apparatus?, :selected_variant, to: :token

    def attributes
      {
        'token_id' => nil,
        'index'    => nil
      }
    end

    def value
      return nil unless apparatus?

      {
        selected_reading:,
        details:
      }
    end

    private

    def selected_reading
      base_reading_for(
        variant:   selected_variant,
        separator: SELECTED_READING_SEPARATOR
      )
    end

    def details
      additional_readings.unshift(selected_reading_witnesses)
                         .join(ENTRIES_SEPARATOR)
    end

    def additional_readings
      additional_variants.map do |variant|
        full_reading_for(variant:)
      end.sort
    end

    def additional_variants
      raise NotImplementedError
    end

    def selected_reading_witnesses
      witnesses_for(variant: selected_variant)
    end
  end
end
