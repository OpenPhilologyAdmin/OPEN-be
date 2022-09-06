# frozen_string_literal: true

class WitnessSerializer
  RECORD_ATTRIBUTES = %i[id default name siglum].freeze

  def initialize(record:)
    @record = record
  end

  def as_json(_options = {})
    @record.as_json(
      only: RECORD_ATTRIBUTES
    )
  end
end
