# frozen_string_literal: true

module Exporter
  module Helpers
    module HasFullMessageErrorsHash
      extend ActiveSupport::Concern

      def errors_hash
        valid?
        errors.to_hash(true)
      end
    end
  end
end
