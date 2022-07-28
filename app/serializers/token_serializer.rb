# frozen_string_literal: true

class TokenSerializer
  RECORD_ATTRIBUTES = %i[id].freeze
  RECORD_METHODS = %i[t apparatus_index].freeze
  EDIT_MODE_RECORD_METHODS = (RECORD_METHODS + %i[state]).freeze

  def initialize(record, edit_mode: false)
    @record = record
    @edit_mode = edit_mode
  end

  def as_json(_options = {})
    @record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: record_methods
    )
  end

  private

  def record_methods
    @edit_mode ? EDIT_MODE_RECORD_METHODS : RECORD_METHODS
  end
end
