# frozen_string_literal: true

module TokensManager
  class Result
    include ActiveModel::Model

    attr_accessor :success, :token
    alias success? success
  end
end
