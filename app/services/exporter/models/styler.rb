# frozen_string_literal: true

module Exporter
  module Models
    class Styler
      def perform(value:, style:)
        public_send("to_#{style}", value:)
      end

      %w[superscript bold paragraph document].each do |style|
        define_method "to_#{style}" do |_value = nil|
          raise NotImplementedError
        end
      end
    end
  end
end
