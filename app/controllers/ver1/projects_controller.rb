# frozen_string_literal: true

module Ver1
  class ProjectsController < ApiApplicationController
    before_action :require_login

    def index
      authorize Project, :index?
      records = policy_scope(Project).includes(:owners).most_recently_updated_first

      render(
        json: RecordsSerializer.new(records)
      )
    end

    def create
      record = Project.new(record_params)
      authorize record, :create?

      if record.save
        ImportProjectJob.perform_now(record.id, current_user.id)
        render(
          json: ProjectSerializer.new(record)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
    end

    def update
      record = Project.find(params[:id])
      authorize record, :update?

      if record.update(record_params.with_defaults(last_editor: current_user))
        render(
          json: ProjectSerializer.new(record)
        )
      else
        respond_with_record_errors(record, :unprocessable_entity)
      end
    end

    def show
      record = Project.find(params[:id])
      authorize record, :show?

      render(
        json: ProjectSerializer.new(record)
      )
    end

    def destroy
      record = Project.find(params[:id])
      authorize record, :destroy?

      record.destroy
      render(
        json:   {
          message: I18n.t('general.notifications.deleted')
        },
        status: :ok
      )
    end

    private

    def record_params
      permitted_attributes(Project)
    end
  end
end
