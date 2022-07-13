# frozen_string_literal: true

class RecordsSerializer
  def initialize(records)
    @records = records
  end

  def as_json(_options = {})
    {
      records: serialized_records,
      count:   @records.size
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
