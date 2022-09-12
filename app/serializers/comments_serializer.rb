# frozen_string_literal: true

class CommentsSerializer < RecordsSerializer
  RECORD_ATTRIBUTES = %i[id body created_at].freeze
  RECORD_METHODS = %i[created_by last_edit_at].freeze

  def as_json(_options = {})
    records.map { |record| CommentSerializer.new(record:).as_json }
  end
end
