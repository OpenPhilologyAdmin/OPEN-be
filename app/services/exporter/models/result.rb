# frozen_string_literal: true

module Exporter
  module Models
    class Result
      include ActiveModel::Model

      attr_accessor :success, :data, :errors
      alias success? success
    end
  end
end
