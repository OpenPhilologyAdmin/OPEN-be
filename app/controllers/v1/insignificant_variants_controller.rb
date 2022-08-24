# frozen_string_literal: true

module V1
  class InsignificantVariantsController < CommonController
    include WithProject

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
