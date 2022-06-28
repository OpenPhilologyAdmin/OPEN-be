# frozen_string_literal: true

module Importer
  module FileValidators
    class TextPlain < Base
      # there are no format validations for txt/plain files
      def validate
        Importer::FileValidationResult.new(errors: [])
      end
    end
  end
end
