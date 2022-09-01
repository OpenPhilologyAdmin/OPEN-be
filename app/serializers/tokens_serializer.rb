# frozen_string_literal: true

class TokensSerializer < RecordsSerializer
  def initialize(records:, edit_mode: false)
    super
    @edit_mode = edit_mode
  end

  private

  attr_reader :edit_mode

  def serialized_records
    apparatus_index = 0
    records.map do |record|
      if record.apparatus?
        apparatus_index += 1
        record.apparatus_index = apparatus_index
      end

      RecordSerializer.new(record:, edit_mode:).as_json
    end
  end

  class RecordSerializer
    RECORD_ATTRIBUTES = %i[id].freeze
    RECORD_METHODS = %i[t apparatus_index].freeze
    EDIT_MODE_RECORD_METHODS = %i[t apparatus_index state].freeze

    def initialize(record:, edit_mode: false)
      @record = record
      @edit_mode = edit_mode
    end

    def as_json(_options = {})
      record.as_json(
        only:    RECORD_ATTRIBUTES,
        methods: record_methods
      )
    end

    private

    attr_reader :record, :edit_mode

    def record_methods
      edit_mode ? EDIT_MODE_RECORD_METHODS : RECORD_METHODS
    end
  end
end
