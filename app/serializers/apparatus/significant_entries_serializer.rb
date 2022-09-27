# frozen_string_literal: true

module Apparatus
  class SignificantEntriesSerializer < EntriesSerializer
    private

    def records_class
      @records_class ||= Apparatus::SignificantEntry
    end

    def serialized_records
      @serialized_records ||= records.map.with_index(STARTING_INDEX) do |record, index|
        next if record.secondary_variants.empty?

        serialized_record(record:, index:)
      end.compact
    end
  end
end
