# frozen_string_literal: true

module TokensManager
  class Resizer
    include EditTrackerHelper

    def initialize(project:, user:, params:)
      @params = Params.new(
        project:,
        selected_token_ids: params[:selected_token_ids]
      )
      @user = user
    end

    def self.perform(project:, user:, params:)
      new(project:, user:, params:).perform
    end

    def perform
      if params.valid?
        perform_updates
        result.success = true
      end
      result
    end

    def result
      @result ||= Result.new(
        success: false,
        params:
      )
    end

    private

    attr_reader :params, :user

    delegate :project, :selected_tokens, to: :params

    def prepared_token
      @prepared_token ||= Preparers::TokenFromMultipleTokens.perform(params:)
    end

    def perform_updates
      Processor.perform(project:, selected_tokens:, prepared_token:)
    end
  end
end
