# frozen_string_literal: true

module V1
  class EditorialRemarksController < CommonController
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
