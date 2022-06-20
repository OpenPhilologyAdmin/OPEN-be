# frozen_string_literal: true

module Importer
  module Concerns
    module Validators
      extend ActiveSupport::Concern

      def valid?
        @errors.empty?
      end

      def perform_validations
        validate_file_presence
      end

      def add_error(key, message)
        @errors[key] = message
      end

      private

      def validate_file_presence
        return if @project.source_file.attached?

        add_error(:file, I18n.t('importer.errors.missing_file'))
      end
    end
  end
end
