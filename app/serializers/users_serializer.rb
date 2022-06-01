# frozen_string_literal: true

class UsersSerializer
  def initialize(records, metadata: {})
    @records            = records
    @metadata           = metadata
  end

  def as_json
    {
      records:      serialized_records,
      count:        @metadata.fetch(:count, @records.size),
      current_page: @metadata.fetch(:page, 1),
      pages:        @metadata.fetch(:pages, 1)
    }
  end

  def serialized_records
    @records.map do |record|
      UserSerializer.new(record).as_json
    end
  end
end
