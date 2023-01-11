# frozen_string_literal: true

module TokensManager
  class Splitter
    def initialize(project:, user:, params:)
      @params = Params.new(
        project:,
        token_id: params[:id]
      )
      @user = user
    end

    def self.perform(project:, user:, params:)
      new(project:, user:, params:).perform
    end

    attr_reader :params, :user

    delegate :project, :token_id, to: :params

    def perform
      if params.valid?
        Processor.perform(project:, source_token: Token.find(params.token_id))
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
  end
end
