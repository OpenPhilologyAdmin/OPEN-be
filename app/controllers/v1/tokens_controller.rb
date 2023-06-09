# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module V1
  class TokensController < CommonController
    include WithProject

    after_action :update_tracking_info, except: %i[index show edited]

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

    def resize
      authorize Token, :resize?

      result =  TokensManager::Resizer.perform(
        project: @project,
        user:    current_user,
        params:  permitted_attributes(Token)
      )

      if result.success?
        render(
          json:   {
            message: I18n.t('tokens.notifications.tokens_width_updated')
          },
          status: :ok
        )
      else
        respond_with_record_errors(result.params, :unprocessable_entity)
      end
    end

    def split
      authorize Token, :split?

      result = TokensManager::Splitter.perform(
        project:      @project,
        user:         current_user,
        source_token: record,
        params:       permitted_attributes(Token)
      )

      if result.success?
        render(
          json:   {
            message: I18n.t('tokens.notifications.token_split')
          },
          status: :ok
        )
      else
        respond_with_record_errors(result.params, :unprocessable_entity)
      end
    end

    def edited
      authorize Token, :edited?

      result =  EditedTokensEvaluator.perform(
        project:            @project,
        selected_token_ids: params[:selected_token_ids]
      )

      render(
        json:   result.as_json,
        status: :ok
      )
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

    def update_tracking_info
      update_last_editor(user: current_user, project: @project)
      update_last_edited_project(project: @project, user: current_user)
    end
  end
end
# rubocop:enable Metrics/ClassLength
