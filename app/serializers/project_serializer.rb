# frozen_string_literal: true

class ProjectSerializer
  RECORD_ATTRIBUTES = %i[id name default_witness witnesses status].freeze
  RECORD_METHODS = %i[created_by creation_date last_edit_date witnesses_count].freeze

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
