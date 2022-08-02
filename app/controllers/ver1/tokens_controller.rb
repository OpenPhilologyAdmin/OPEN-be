# frozen_string_literal: true

module Ver1
  class TokensController < ApiApplicationController
    include WithProject

    before_action :require_login

    def index
      authorize Token, :index?

      render(
        json: TokensSerializer.new(records, mode:)
      )
    end

    def show
      record = records.find(params[:id])
      authorize record, :show?

      render(
        json: TokenSerializer.new(record, mode:)
      )
    end

    def update
      record = records.find(params[:id])
      authorize record, :update?

      result = TokensManager::Updater.perform!(
        token:  record,
        user:   current_user,
        params: permitted_attributes(Token)
      )

      if result.success?
        render(
          json: TokenSerializer.new(result.token, mode:)
        )
      else
        respond_with_record_errors(result.token, :unprocessable_entity)
      end
    end

    private

    def records
      @records ||= policy_scope(Token).for_project(@project).includes(:project)
    end

    def mode
      return :edit_token if %w[show update].include?(action_name)
      return :edit_project if edit_project_mode?

      TokenSerializer::DEFAULT_MODE
    end

    def edit_project_mode?
      ActiveModel::Type::Boolean.new.cast(params[:edit_mode])
    end
  end
end
