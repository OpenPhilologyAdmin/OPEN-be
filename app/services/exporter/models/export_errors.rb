# frozen_string_literal: true

module Exporter
  module Models
    class ExportErrors
      def initialize(exporter_options:, apparatus_options:)
        @exporter_options = exporter_options
        @apparatus_options = apparatus_options
      end

      def errors
        @errors ||= apparatus_options_errors_hash.merge(
          exporter_options_errors_hash
        )
      end

      private

      attr_reader :exporter_options, :apparatus_options

      delegate :errors_hash, to: :apparatus_options, prefix: true
      delegate :errors_hash, to: :exporter_options, prefix: true
    end
  end
end
