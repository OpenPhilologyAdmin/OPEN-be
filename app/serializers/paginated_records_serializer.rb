# frozen_string_literal: true

class PaginatedRecordsSerializer
  def initialize(records, metadata: {})
    @records = records
    @metadata = metadata
  end

  def as_json(_options = {})
    {
      records:      serialized_records,
      count:        @metadata.fetch(:count, @records.size),
      current_page: @metadata.fetch(:page, 1),
      pages:        @metadata.fetch(:pages, 1)
    }
  end

  private

  def records_class
    @records_class ||= @records.first.class.name
  end

  def record_serializer
    @record_serializer ||= "#{records_class}Serializer".constantize
  end

  def serialized_records
    @records.map do |record|
      record_serializer.new(record).as_json
    end
  end
end
