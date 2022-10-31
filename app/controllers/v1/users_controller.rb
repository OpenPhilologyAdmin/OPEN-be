# frozen_string_literal: true

module V1
  class UsersController < CommonController
    skip_before_action :authenticate_user!, only: [:create]

    def index
      authorize User, :index?
      records = policy_scope(User).most_recent_first

      render(
        json: RecordsSerializer.new(records:)
      )
    end

    def create
      record = User.new(permitted_attributes(User))
      authorize record, :create?
      if record.save
        render(
          json: UserSerializer.new(record:)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
    end

    def approve
      record          = authorize(User.find(params[:id]))
      record_approved = record.approve!
      NotificationMailer.account_approved(record).deliver_later if record_approved

      render(
        json: UserSerializer.new(record:)
      )
    end

    def me
      record = authorize current_user
      render(
        json: UserSerializer.new(record:)
      )
    end

    def last_edited_project
      record = User.find(params[:id])
      authorize record, :last_edited_project?

      render(
        json: record.as_json(only: [:last_edited_project_id]), status: :ok
      )
    end
  end
end
