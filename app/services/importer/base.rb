# frozen_string_literal: true

module Importer
  class Base
    ALLOWED_MIME_TYPES = ['text/plain'].freeze

    attr_reader :errors

    def initialize(data_path: nil)
      @data_path = Rails.root.join(data_path)
      @errors    = {}
    end

    def valid?
      @errors.empty?
    end

    private

    def validate_file_format
      return if ALLOWED_MIME_TYPES.include?(Marcel::MimeType.for(@data_path, name: @data_path.basename))

      @errors[:file] = I18n.t('importer.errors.invalid_file_format')
    end
  end
end
