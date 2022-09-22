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

    def update
      authorize record, :update?

      if record.update(record_params)
        render(
          json: CommentSerializer.new(record:)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
    end

    def destroy
      record = Comment.find(params[:id])
      authorize record, :destroy?

      record.deleted = true
      record.save

      render(
        json:   { message: I18n.t('general.notifications.deleted') },
        status: :ok
      )
    end

    private

    def token
      @token ||= Token.find_by(id: params[:token_id], project_id: params[:project_id])
    end

    def records
      @records ||= token.comments
    end

    def record
      @record ||= records.find(params[:id])
    end

    def record_params
      permitted_attributes(Comment)
    end
  end
end
