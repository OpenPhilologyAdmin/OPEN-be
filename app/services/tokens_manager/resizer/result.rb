# frozen_string_literal: true

module TokensManager
  class Resizer
    class Result
      include ActiveModel::Model
      attr_accessor :success
      attr_reader :params

      def initialize(success:, params:)
        @success = success
        @params = params
      end

      alias success? success
    end
  end
end
