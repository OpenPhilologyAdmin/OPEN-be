# frozen_string_literal: true

module Apparatus
  class EntriesSerializer < RecordsSerializer
    STARTING_INDEX = 1

    def initialize(records:, significant: true)
      super
      @significant = significant
    end

    private

    def record_serializer
      @record_serializer ||= Apparatus::EntrySerializer
    end

    def records_class
      @records_class ||= "Apparatus::#{@significant ? 'Significant' : 'Insignificant'}Entry".constantize
    end

    def serialized_records
      records.map.with_index(STARTING_INDEX) do |record, index|
        record_serializer.new(
          records_class.new(token: record, index:)
        ).as_json
      end
    end
  end
end
