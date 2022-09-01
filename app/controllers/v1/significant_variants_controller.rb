# frozen_string_literal: true

module V1
  class SignificantVariantsController < CommonController
    include WithProject

    def index
      authorize Token, :significant_variants?
      records = policy_scope(Token).for_project(@project)
                                   .for_apparatus
                                   .includes(:project)

      render(
        json: Apparatus::EntriesSerializer.new(records:, significant: true)
      )
    end
  end
end
