# frozen_string_literal: true

module Ver1
  class WitnessesController < ApiApplicationController
    before_action :require_login

    def index
      record = Project.find(params[:project_id])
      authorize Project, :show?
      pagy, records = pagy_array(record.witnesses)

      render(
        json: PaginatedRecordsSerializer.new(
          records,
          metadata: pagy_metadata(pagy)
        )
      )
    end
  end
end
