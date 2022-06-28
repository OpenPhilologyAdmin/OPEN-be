# frozen_string_literal: true

module Importer
  module Concerns
    module Validators
      extend ActiveSupport::Concern
      INVALID_STATUS = :invalid

      def valid?
        import_errors.empty?
      end

      def perform_validations
        validate_file_presence
        return unless valid?

        validate_file_format
      end

      def add_error(key, message)
        import_errors[key] = message
        update_project
      end

      private

      def update_project
        project.invalidate!
      end

      def validate_file_presence
        return if project.source_file.attached?

        add_error(:file, I18n.t('importer.errors.missing_file'))
      end

      def file_validator
        @file_validator ||= "Importer::FileValidators::#{processed_mime_type}"
                            .constantize
                            .new(project:)
      end

      def validate_file_format
        result = file_validator.validate

        return if result.success?

        add_error(:file_format, result.errors)
      end
    end
  end
end
