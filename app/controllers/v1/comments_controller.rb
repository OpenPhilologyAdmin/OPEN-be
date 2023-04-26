# frozen_string_literal: true

module V1
  class CommentsController < CommonController
    include WithProject

    after_action :update_tracking_info, except: :index

    def index
      authorize records, :index?

      render(
        json: CommentsSerializer.new(records:)
      )
    end

    def create
      record = records.build(record_params.with_defaults(user: current_user))

      authorize record, :create?

      if record.save
        render(
          json: CommentSerializer.new(record:)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
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
      record = records.find(params[:id])
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
      @token ||= policy_scope(Token).find_by(id: params[:token_id], project: @project)
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

    def update_tracking_info
      update_last_editor(user: current_user, project: @project)
      update_last_edited_project(project: @project, user: current_user)
    end
  end
end
