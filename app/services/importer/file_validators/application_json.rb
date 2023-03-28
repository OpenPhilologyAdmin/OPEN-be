# frozen_string_literal: true

module Importer
  module FileValidators
    class ApplicationJson < Base
      REQUIRED_KEYS = %w[witnesses table].freeze

      def validate
        parse_file_contents
        if @errors.empty?
          validate_required_keys
          validate_witnesses
          validate_table
        end

        Importer::FileValidationResult.new(errors: @errors)
      end

      private

      def add_error(error_message)
        @errors << error_message
      end

      def witnesses
        @witnesses ||= @file_content['witnesses']
      end

      def table
        @table ||= @file_content['table']
      end

      def parse_file_contents
        @file_content = JSON.parse(source_file.open(&:read))
      rescue JSON::ParserError
        add_error(I18n.t('importer.errors.json_files.invalid_json'))
        @file_content = ''
      end

      def validate_required_keys
        return if (REQUIRED_KEYS - file_content.keys).empty?

        add_error(I18n.t('importer.errors.json_files.missing_keys'))
      end

      def validate_witnesses
        return if witnesses.is_a?(Array) && !witnesses.empty?

        add_error(I18n.t('importer.errors.json_files.missing_witnesses'))
      end

      def validate_table
        return if witnesses.blank? || table.blank?

        return if table.all? { |tokens| tokens.size == witnesses.size }

        add_error(I18n.t('importer.errors.json_files.incorrect_number_of_tokens'))
      end
    end
  end
end
