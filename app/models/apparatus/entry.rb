# frozen_string_literal: true

module Apparatus
  class Entry
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

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
      raise NotImplementedError
    end

    private

    def reading_for(variant:, separator: nil, include_witnesses: true)
      value = "#{value_for(variant)}#{separator}"
      return value unless include_witnesses

      "#{value} #{witnesses_for(variant)}"
    end

    # use the :formatted_t, so the entry is correctly displayed in the apparatus
    def value_for(variant)
      variant.formatted_t.strip
    end

    def witnesses_for(variant)
      variant.witnesses.join(' ')
    end

    def selected_reading
      reading_for(variant: selected_variant, separator: ']', include_witnesses: false)
    end
  end
end
