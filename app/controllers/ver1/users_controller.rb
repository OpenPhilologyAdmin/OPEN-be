# frozen_string_literal: true

module Ver1
  class UsersController < ApiApplicationController
    before_action :require_login, except: [:create]

    def index
      authorize User, :index?
      pagy, records = pagy(policy_scope(User))

      render(
        json: UsersSerializer.new(
          records,
          metadata: pagy_metadata(pagy)
        ).as_json
      )
    end

    def create
      record = User.new(permitted_attributes(User))
      authorize record, :create?
      if record.save
        render(
          json: UserSerializer.new(record).as_json
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
        json: UserSerializer.new(record).as_json
      )
    end
  end
end
