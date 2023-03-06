# frozen_string_literal: true

module Exporter
  module Models
    class ExportErrors
      def initialize(apparatus_options:)
        @apparatus_options = apparatus_options
      end

      def errors
        @errors ||= apparatus_options_errors_hash
      end

      private

      attr_reader :apparatus_options

      delegate :errors_hash, to: :apparatus_options, prefix: true
    end
  end
end
