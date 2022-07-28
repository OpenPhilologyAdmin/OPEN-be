# frozen_string_literal: true

class TokenSerializer
  RECORD_ATTRIBUTES = %i[id].freeze
  RECORD_METHODS = %i[t apparatus_index].freeze
  EDIT_MODE_RECORD_METHODS = (RECORD_METHODS + %i[state]).freeze
  VERBOSE_RECORD_METHODS = %i[grouped_variants].freeze

  def initialize(record, edit_mode: false, verbose: false)
    @record = record
    @edit_mode = edit_mode
    @verbose = verbose
  end

  def as_json(_options = {})
    @record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: record_methods
    )
  end

  private

  def record_methods
    return EDIT_MODE_RECORD_METHODS if @edit_mode
    return VERBOSE_RECORD_METHODS if @verbose

    RECORD_METHODS
  end
end
