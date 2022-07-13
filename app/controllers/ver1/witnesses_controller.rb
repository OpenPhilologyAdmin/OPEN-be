# frozen_string_literal: true

module Ver1
  class WitnessesController < ApiApplicationController
    before_action :require_login
    before_action :fetch_project

    def index
      authorize @project, :index_witnesses?

      render(
        json: RecordsSerializer.new(@project.witnesses)
      )
    end

    def update
      authorize @project, :update_witnesses?
      result = WitnessesManager::Updater.perform!(
        project: @project,
        siglum:  witness_siglum,
        params:  permitted_attributes(Witness)
      )

      if result.success?
        render(
          json: WitnessSerializer.new(result.witness)
        )
      else
        respond_with_record_errors(result.witness, :unprocessable_entity)
      end
    end

    def destroy
      authorize @project, :destroy_witnesses?
      WitnessesManager::Remover.perform!(
        project: @project,
        siglum:  witness_siglum
      )
      render(
        json:   {
          message: I18n.t('general.notifications.deleted')
        },
        status: :ok
      )
    end

    private

    def fetch_project
      @project = Project.find(params[:project_id])
    end

    def witness_siglum
      @witness_siglum ||= params[:id]
    end
  end
end
