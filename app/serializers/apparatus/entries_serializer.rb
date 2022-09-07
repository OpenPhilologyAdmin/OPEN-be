# frozen_string_literal: true

module Apparatus
  class EntriesSerializer < RecordsSerializer
    STARTING_INDEX = 1

    def as_json(_options = {})
      {
        records: serialized_records,
        count:   serialized_records.size
      }
    end

    private

    def record_serializer
      @record_serializer ||= Apparatus::EntrySerializer
    end

    def serialized_records
      raise NotImplementedError
    end

    def serialized_record(record:, index:)
      record_serializer.new(
        records_class.new(token: record, index:)
      ).as_json
    end
  end
end
