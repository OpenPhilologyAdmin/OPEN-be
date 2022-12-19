# frozen_string_literal: true

module V1
  class ProjectsController < CommonController
    after_action :update_tracking_info, except: %i[index show destroy]

    def index
      authorize Project, :index?
      records = policy_scope(Project).includes(:owners)
                                     .most_recently_updated_first
                                     .processed

      render(
        json: RecordsSerializer.new(records:)
      )
    end

    def show
      record = Project.find(params[:id])
      authorize record, :show?

      render(
        json: ProjectSerializer.new(record:)
      )
    end

    def create
      @record = Project.new(record_params)
      authorize @record, :create?

      if @record.save
        ImportProjectJob.perform_now(@record.id, current_user.id, @record.default_witness_name)
        render(
          json: ProjectSerializer.new(record: @record)
        )
      else
        respond_with_record_errors(@record, :unprocessable_entity)
      end
    end

    def update
      @record = Project.find(params[:id])
      authorize @record, :update?

      if @record.update(record_params.with_defaults(last_editor: current_user))
        render(
          json: ProjectSerializer.new(record: @record)
        )
      else
        respond_with_record_errors(@record, :unprocessable_entity)
      end
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

    def export
      @record = Project.find(params[:id])
      authorize @record, :export?

      result = Exporter::Base.perform(
        project: @record,
        options: record_params
      )

      if result.success?
        send_data(result.data,
                  filename: "#{@record.name}.rtf",
                  type:     'application/rtf')
      else
        respond_with_record_errors(result, :unprocessable_entity)
      end
    end

    private

    def record_params
      permitted_attributes(Project)
    end

    def update_tracking_info
      update_last_editor(user: current_user, project: @record)
      update_last_edited_project(project: @record, user: current_user)
    end
  end
end
