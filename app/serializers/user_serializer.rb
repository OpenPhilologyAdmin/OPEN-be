# frozen_string_literal: true

class UserSerializer
  RECORD_ATTRIBUTES = %i[id email name role zip_code last_edited_project_id].freeze
  RECORD_METHODS    = %i[registration_date account_approved].freeze

  def initialize(record:)
    @record = record
  end

  def as_json(_options = {})
    @record.as_json(
      only:    RECORD_ATTRIBUTES,
      methods: RECORD_METHODS
    )
  end
end
