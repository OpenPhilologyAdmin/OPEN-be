# frozen_string_literal: true

module V1
  class TokensController < CommonController
    include WithProject

    def index
      authorize Token, :index?

      render(
        json: TokensSerializer.new(records:, edit_mode:)
      )
    end

    def show
      authorize record, :show?

      render(
        json: TokenSerializer.new(record:)
      )
    end

    def update_grouped_variants
      authorize record, :update_grouped_variants?
      result = TokensManager::GroupedVariantsUpdater.perform(
        token:  record,
        user:   current_user,
        params: permitted_attributes(Token)
      )

      handle_token_update(result)
    end

    def update_variants
      authorize record, :update_variants?
      result =  TokensManager::VariantsUpdater.perform(
        token:  record,
        user:   current_user,
        params: permitted_attributes(Token)
      )

      handle_token_update(result)
    end

    private

    def records
      @records ||= policy_scope(Token).for_project(@project).includes(:project)
    end

    def record
      @record ||= records.find(params[:id])
    end

    def edit_mode
      ActiveModel::Type::Boolean.new.cast(params[:edit_mode])
    end

    def handle_token_update(result)
      if result.success?
        render(
          json: TokenSerializer.new(record: result.token)
        )
      else
        respond_with_record_errors(result.token, :unprocessable_entity)
      end
    end
  end
end
