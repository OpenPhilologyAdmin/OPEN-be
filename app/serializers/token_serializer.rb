# frozen_string_literal: true

class TokenSerializer
  RECORD_ATTRIBUTES = %i[id].freeze
  DEFAULT_MODE      = :standard
  RECORD_METHODS    = {
    "#{DEFAULT_MODE}": %i[t apparatus_index],
    edit_project:      %i[t apparatus_index state],
    edit_token:        %i[grouped_variants variants]
  }.freeze

  def initialize(record, mode: DEFAULT_MODE)
    @record = record
    @mode   = mode
  end

  def as_json(_options = {})
    @record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: record_methods
    )
  end

  private

  def record_methods
    return RECORD_METHODS[DEFAULT_MODE] unless RECORD_METHODS.key?(@mode)

    RECORD_METHODS[@mode]
  end
end
