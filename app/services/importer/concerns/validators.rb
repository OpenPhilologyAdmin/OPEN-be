# frozen_string_literal: true

module Importer
  module Concerns
    module Validators
      extend ActiveSupport::Concern
      ALLOWED_MIME_TYPES = ['text/plain'].freeze

      def valid?
        @errors.empty?
      end

      def perform_validations
        validate_mime_type
      end

      def add_error(key, message)
        @errors[key] = message
      end

      private

      def validate_mime_type
        return if ALLOWED_MIME_TYPES.include?(mime_type)

        add_error(:file, I18n.t('importer.errors.invalid_file_format'))
      end
    end
  end
end
