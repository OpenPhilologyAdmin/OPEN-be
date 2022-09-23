# frozen_string_literal: true

class CommentsSerializer < RecordsSerializer
  def as_json(_options = {})
    records.map { |record| CommentSerializer.new(record:).as_json }
  end
end
