# frozen_string_literal: true

module Apparatus
  class Entry
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON

    attr_accessor :token, :index

    delegate :id, to: :token, prefix: true
    delegate :apparatus?, to: :token

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
      value = "#{variant.t.strip}#{separator}"
      return value unless include_witnesses

      "#{value} #{witnesses_for(variant)}"
    end

    def witnesses_for(variant)
      variant.witnesses.join(' ')
    end
  end
end
