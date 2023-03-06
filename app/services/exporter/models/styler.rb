# frozen_string_literal: true

module Exporter
  module Models
    class Styler
      def perform(value:, style:, options: {})
        public_send("to_#{style}", value:, options:)
      end

      %w[superscript bold paragraph document indented_line color].each do |style|
        define_method "to_#{style}" do |_value = nil|
          raise NotImplementedError
        end
      end
    end
  end
end
