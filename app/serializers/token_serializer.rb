# frozen_string_literal: true

class TokenSerializer
  RECORD_ATTRIBUTES = %i[id].freeze
  RECORD_METHODS = %i[t apparatus_index].freeze

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
