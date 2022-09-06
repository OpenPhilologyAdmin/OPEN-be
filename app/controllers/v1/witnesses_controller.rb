# frozen_string_literal: true

module V1
  class WitnessesController < CommonController
    include WithProject

    def index
      authorize @project, :index_witnesses?

      render(
        json: RecordsSerializer.new(records: @project.witnesses)
      )
    end

    def create
      authorize @project, :create_witnesses?
      result = WitnessesManager::Creator.perform(
        project: @project,
        user:    current_user,
        params:  permitted_attributes(Witness)
      )

      if result.success?
        render(
          json: WitnessSerializer.new(record: result.witness)
        )
      else
        respond_with_record_errors(result.witness, :unprocessable_entity)
      end
    end

    def update
      authorize @project, :update_witnesses?
      result = WitnessesManager::Updater.perform(
        project: @project,
        siglum:  witness_siglum,
        user:    current_user,
        params:  permitted_attributes(Witness)
      )

      if result.success?
        render(
          json: WitnessSerializer.new(record: result.witness)
        )
      else
        respond_with_record_errors(result.witness, :unprocessable_entity)
      end
    end

    def destroy
      authorize @project, :destroy_witnesses?
      WitnessesManager::Remover.perform(
        project: @project,
        user:    current_user,
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

    def witness_siglum
      @witness_siglum ||= params[:id]
    end
  end
end
