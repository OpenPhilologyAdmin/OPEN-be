# frozen_string_literal: true

module Ver1
  class TokensController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize Token, :index?
      records = policy_scope(Token).for_project(@project).includes(:project)

      render(
        json: TokensSerializer.new(records, edit_mode:)
      )
    end

    private

    def edit_mode
      ActiveModel::Type::Boolean.new.cast(params[:edit_mode])
    end
  end
end
