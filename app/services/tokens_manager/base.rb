# frozen_string_literal: true

module TokensManager
  class Base
    def initialize(token:, user:, params: {})
      @token = token
      @params = params
      @user = user
    end

    def self.perform(token:, user:, params: {})
      new(token:, user:, params:).perform
    end

    def perform
      raise NotImplementedError
    end

    private

    attr_reader :token, :params, :user
  end
end
