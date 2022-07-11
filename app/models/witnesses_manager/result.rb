# frozen_string_literal: true

module WitnessesManager
  class Result
    include ActiveModel::Model

    attr_accessor :success, :witness
    alias success? success
  end
end
