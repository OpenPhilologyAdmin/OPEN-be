# frozen_string_literal: true

module Importer
  class FileValidationResult
    include ActiveModel::Model

    attr_accessor :errors

    def success?
      errors.empty?
    end
  end
end
