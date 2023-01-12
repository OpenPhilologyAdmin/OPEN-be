# frozen_string_literal: true

module TokensManager
  class Splitter
    def initialize(project:, user:, params:)
      @params = Params.new(
        project:,
        token_id:     params[:id],
        new_variants: params[:variants]
      )
      @user = user
    end

    def self.perform(project:, user:, params:)
      new(project:, user:, params:).perform
    end

    attr_reader :params, :user

    delegate :project, :token_id, :new_variants, to: :params

    def perform
      if params.valid?
        source_token = Token.find_by(token_id)
        Processor.perform(project:, source_token:, new_variants:)
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
