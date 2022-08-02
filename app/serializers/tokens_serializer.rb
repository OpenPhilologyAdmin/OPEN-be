# frozen_string_literal: true

class TokensSerializer < RecordsSerializer
  def initialize(records, mode: nil)
    super
    @mode = mode
  end

  private

  def serialized_records
    apparatus_index = 0
    @records.map do |record|
      if record.apparatus?
        apparatus_index += 1
        record.apparatus_index = apparatus_index
      end

      record_serializer.new(record, mode: @mode).as_json
    end
  end
end
