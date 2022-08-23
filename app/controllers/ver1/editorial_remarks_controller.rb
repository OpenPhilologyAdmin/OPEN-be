# frozen_string_literal: true

module Ver1
  class EditorialRemarksController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize @project, :editorial_remark_types?

      render(
        json: TokenEditorialRemark::EDITORIAL_REMARK_TYPES.to_json
      )
    end
  end
end
