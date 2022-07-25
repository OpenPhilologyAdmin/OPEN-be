# frozen_string_literal: true

module Apparatus
  class Entry
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :token, :index

    delegate :id, to: :token, prefix: true
    delegate :apparatus?, :selected_variant, :secondary_variants, to: :token

    def attributes
      {
        'token_id' => nil,
        'index'    => nil
      }
    end

    def value
      return nil unless apparatus?

      ([selected_reading] + secondary_readings).join(', ')
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

    def reading_for(variant:, separator: nil)
      "#{variant.t.strip}#{separator} #{variant.witnesses.join(' ')}"
    end
  end
end
