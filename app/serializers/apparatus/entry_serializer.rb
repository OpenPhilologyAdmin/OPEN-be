# frozen_string_literal: true

module Apparatus
  class EntrySerializer
    RECORD_ATTRIBUTES = %i[token_id index].freeze
    RECORD_METHODS = %i[value].freeze

    def initialize(record)
      @record = record
    end

    def as_json(_options = {})
      @record.as_json(
        only:    RECORD_ATTRIBUTES,
        methods: RECORD_METHODS
      )
    end
  end
end
