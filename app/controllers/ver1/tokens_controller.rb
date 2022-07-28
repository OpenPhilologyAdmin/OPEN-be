# frozen_string_literal: true

module Ver1
  class TokensController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize Token, :index?

      render(
        json: TokensSerializer.new(records, edit_mode:)
      )
    end

    def show
      record = records.find(params[:id])
      authorize record, :show?

      render(
        json: TokenSerializer.new(record, verbose: true)
      )
    end

    private

    def records
      @records ||= policy_scope(Token).for_project(@project).includes(:project)
    end

    def edit_mode
      ActiveModel::Type::Boolean.new.cast(params[:edit_mode])
    end
  end
end
