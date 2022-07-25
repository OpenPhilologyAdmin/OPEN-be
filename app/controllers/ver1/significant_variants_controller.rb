# frozen_string_literal: true

module Ver1
  class SignificantVariantsController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize Token, :significant_variants?
      records = policy_scope(Token).for_project(@project)
                                   .for_apparatus
                                   .includes(:project)

      render(
        json: Apparatus::EntriesSerializer.new(records)
      )
    end
  end
end
