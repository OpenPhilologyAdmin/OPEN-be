# frozen_string_literal: true

module Apparatus
  class Entry
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include Concerns::FormattableReading

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

    def selected_reading
      base_reading_for(variant: selected_variant, separator: ']')
    end

    def selected_reading_witnesses
      witnesses_for(variant: selected_variant)
    end
  end
end
