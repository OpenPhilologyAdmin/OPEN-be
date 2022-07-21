# frozen_string_literal: true

class TokensSerializer < RecordsSerializer
  private

  def serialized_records
    apparatus_index = 0
    @records.map do |record|
      if record.apparatus?
        apparatus_index += 1
        record.apparatus_index = apparatus_index
      end

      record_serializer.new(record).as_json
    end
  end
end
