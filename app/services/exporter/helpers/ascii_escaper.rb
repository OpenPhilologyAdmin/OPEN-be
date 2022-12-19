# frozen_string_literal: true

module Exporter
  module Helpers
    module AsciiEscaper
      NIL_VALUE_ASCII_PLACEHOLDER = Regexp.escape("\\'d8")

      def to_escaped_string(value:)
        value.gsub(/#{FormattableT::NIL_VALUE_PLACEHOLDER}/, NIL_VALUE_ASCII_PLACEHOLDER)
      end
    end
  end
end
