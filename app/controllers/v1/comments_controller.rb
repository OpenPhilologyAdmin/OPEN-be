# frozen_string_literal: true

module V1
  class CommentsController < CommonController
    include WithProject

    def index
      authorize Comment, :index?

      render(
        json: CommentsSerializer.new(records:)
      )
    end

    def create
      record = token.comments.build(record_params)

      authorize record, :create?

      if record.save
        render(
          json: CommentSerializer.new(record:)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
    end

    private

    def token
      @token ||= Token.find_by(id: params[:token_id], project_id: params[:project_id])
    end

    def records
      @records ||= token.comments
    end

    def record_params
      permitted_attributes(Comment)
    end
  end
end
