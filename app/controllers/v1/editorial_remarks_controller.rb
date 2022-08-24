# frozen_string_literal: true

module V1
  class EditorialRemarksController < CommonController
    def index
      authorize TokenEditorialRemark, :index?

      render(
        json: TokenEditorialRemark::EDITORIAL_REMARK_TYPES.to_json
      )
    end
  end
end
