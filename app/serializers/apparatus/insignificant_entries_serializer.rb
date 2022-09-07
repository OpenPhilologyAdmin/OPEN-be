# frozen_string_literal: true

module Apparatus
  class InsignificantEntriesSerializer < EntriesSerializer
    private

    def records_class
      @records_class ||= Apparatus::InsignificantEntry
    end

    def skip_record?(record)
      record.insignificant_variants.empty?
    end

    def serialized_records
      @serialized_records ||= records.map.with_index(STARTING_INDEX) do |record, index|
        next if skip_record?(record)

        serialized_record(record:, index:)
      end.compact
    end
  end
end
