# frozen_string_literal: true

module Ver1
  class ProjectsController < ApiApplicationController
    before_action :require_login

    def index
      authorize Project, :index?
      pagy, records = pagy(policy_scope(Project).includes(:owners))

      render(
        json: PaginatedRecordsSerializer.new(
          records,
          metadata: pagy_metadata(pagy)
        )
      )
    end

    def create
      record = Project.new(permitted_attributes(Project))
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

    def show
      record = Project.find(params[:id])
      authorize record, :show?

      render(
        json: ProjectSerializer.new(record)
      )
    end
  end
end
