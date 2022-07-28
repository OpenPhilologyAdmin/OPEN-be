# frozen_string_literal: true

module Helpers
  module ApparatusSerializer
    def serialized_entry(entry)
      ::Apparatus::EntrySerializer.new(entry).as_json
    end

    def serialized_entries(entries)
      entries.map { |entry| serialized_entry(entry) }
    end
  end
end
