# frozen_string_literal: true

class ProjectSerializer
  RECORD_ATTRIBUTES = %i[id name default_witness witnesses].freeze

  def initialize(record)
    @record = record
  end

  def as_json
    @record.as_json(
      only: RECORD_ATTRIBUTES
    )
  end
end
