# frozen_string_literal: true

module TokensManager
  class Resizer
    include EditTrackerHelper

    def initialize(project:, user:, params:)
      @params = Params.new(
        project:,
        selected_text:       params[:selected_text],
        selected_token_ids:  params[:selected_token_ids],
        tokens_with_offsets: params[:tokens_with_offsets]
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

    def perform_updates
      update_tokens
    end

    def update_tokens
      prepared_tokens = Preparer.perform(params:)
      Processor.perform(project:, selected_tokens:, prepared_tokens:)
    end
  end
end
