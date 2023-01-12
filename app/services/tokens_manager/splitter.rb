# frozen_string_literal: true

module TokensManager
  class Splitter
    def initialize(project:, user:, source_token:, params:)
      @params = Params.new(
        project:,
        new_variants: params[:variants]
      )
      @user = user
      @source_token = source_token
    end

    def self.perform(project:, user:, source_token:, params:)
      new(project:, user:, source_token:, params:).perform
    end

    attr_reader :params, :user, :source_token

    delegate :project, :new_variants, to: :params

    def perform
      if params.valid?
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
