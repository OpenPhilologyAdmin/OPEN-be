# frozen_string_literal: true

class UserSerializer
  RECORD_ATTRIBUTES = %i[id email name role zip_code].freeze
  RECORD_METHODS    = %i[account_approved].freeze

  def initialize(record)
    @record = record
  end

  def as_json
    @record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: RECORD_METHODS
    )
  end
end
