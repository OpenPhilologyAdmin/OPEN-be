# frozen_string_literal: true

module Apparatus
  class EntriesSerializer < RecordsSerializer
    STARTING_INDEX = 1

    private

    def record_serializer
      @record_serializer ||= Apparatus::EntrySerializer
    end

    def serialized_records
      @records.map.with_index(STARTING_INDEX) do |record, index|
        record_serializer.new(
          Apparatus::Entry.new(token: record, index:)
        ).as_json
      end
    end
  end
end
