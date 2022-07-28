# frozen_string_literal: true

module Ver1
  class InsignificantVariantsController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize Token, :insignificant_variants?
      records = policy_scope(Token).for_project(@project)
                                   .for_apparatus
                                   .with_insignificant_variants
                                   .includes(:project)

      render(
        json: Apparatus::EntriesSerializer.new(records, significant: false)
      )
    end
  end
end
