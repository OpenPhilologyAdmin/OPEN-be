# frozen_string_literal: true

class CommentSerializer
  RECORD_ATTRIBUTES = %i[id body token_id created_at].freeze
  RECORD_METHODS = %i[created_by last_edit_at].freeze

  def initialize(record:)
    @record = record
  end

  def as_json(_options = {})
    record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: RECORD_METHODS
    )
  end

  attr_reader :record
end
